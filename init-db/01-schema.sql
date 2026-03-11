CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE OR REPLACE FUNCTION uuid_generate_v7()
RETURNS uuid AS $$
DECLARE
    timestamp    timestamptz;
    microseconds bigint;
    unix_millis  bigint;
    uuid_hex     text;
BEGIN
    timestamp    := clock_timestamp();
    unix_millis  := (EXTRACT(EPOCH FROM timestamp) * 1000)::bigint;
    microseconds := (EXTRACT(MICROSECONDS FROM timestamp))::bigint % 1000;
    
    uuid_hex := lpad(to_hex(unix_millis), 12, '0') || '7' || 
                lpad(to_hex(microseconds), 3, '0') || 
                encode(gen_random_bytes(8), 'hex');
    
    RETURN uuid_hex::uuid;
END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE TABLE roles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v7(),
    name VARCHAR(20) NOT NULL,
    description VARCHAR(100) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ
);

CREATE TABLE stations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v7(),
    name VARCHAR(100) NOT NULL,
    address VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ
);

CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v7(),
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(255),
    password VARCHAR(255),
    phone VARCHAR(15),
    sex INT, 
    date_of_birth TIMESTAMPTZ,
    avatar_url VARCHAR(500),
    avatar_public_id VARCHAR(255),
    is_google_linked BOOLEAN NOT NULL DEFAULT FALSE,
    has_seen_tutorial BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    role_id UUID NOT NULL,
    CONSTRAINT fk_users_roles FOREIGN KEY (role_id) REFERENCES roles(id)
);
CREATE INDEX idx_users_role_id ON users (role_id);

CREATE TABLE staffs (
    user_id UUID PRIMARY KEY,
    deleted_at TIMESTAMPTZ,
    station_id UUID NOT NULL,
    CONSTRAINT fk_staff_users FOREIGN KEY (user_id) REFERENCES users(id),
    CONSTRAINT fk_staff_stations FOREIGN KEY (station_id) REFERENCES stations(id)
);
CREATE INDEX idx_staffs_station_id ON staffs (station_id);

CREATE TABLE tickets (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v7(),
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    reply TEXT,
    status INT NOT NULL DEFAULT 0,
    type INT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    station_id UUID,
    requester_id UUID,
    assignee_id UUID,
    CONSTRAINT fk_tickets_stations FOREIGN KEY (station_id) REFERENCES stations(id),
    CONSTRAINT fk_tickets_users FOREIGN KEY (requester_id) REFERENCES users(id),
    CONSTRAINT fk_tickets_staffs FOREIGN KEY (assignee_id) REFERENCES staffs(user_id)
);
CREATE INDEX idx_tickets_station_id ON tickets (station_id);
CREATE INDEX idx_tickets_requester_id ON tickets (requester_id);
CREATE INDEX idx_tickets_assignee_id ON tickets (assignee_id);

CREATE TABLE refresh_tokens (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v7(),
    token TEXT NOT NULL,
    issued_at TIMESTAMPTZ NOT NULL,
    expires_at TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    is_revoked BOOLEAN NOT NULL DEFAULT FALSE,
    user_id UUID NOT NULL,
    CONSTRAINT fk_refresh_users FOREIGN KEY (user_id) REFERENCES users(id)
);
CREATE INDEX idx_refresh_tokens_user_id ON refresh_tokens (user_id);

CREATE TABLE driver_licenses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v7(),
    number VARCHAR(20) NOT NULL,
    class INT NOT NULL, 
    full_name VARCHAR(100) NOT NULL,
    nationality VARCHAR(50) NOT NULL,
    sex INT NOT NULL DEFAULT 0, 
    date_of_birth TIMESTAMPTZ NOT NULL,
    expires_at TIMESTAMPTZ NOT NULL,
    front_image_url VARCHAR(500) NOT NULL,
    front_image_public_id VARCHAR(255) NOT NULL,
    back_image_url VARCHAR(500) NOT NULL,
    back_image_public_id VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    user_id UUID NOT NULL,
    CONSTRAINT fk_driver_users FOREIGN KEY (user_id) REFERENCES users(id)
);
CREATE INDEX idx_driver_licenses_user_id ON driver_licenses (user_id);

CREATE TABLE citizen_identities (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v7(),
    number VARCHAR(20) NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    nationality VARCHAR(50) NOT NULL,
    sex INT NOT NULL DEFAULT 0, 
    date_of_birth TIMESTAMPTZ NOT NULL,
    expires_at TIMESTAMPTZ NOT NULL,
    front_image_url VARCHAR(500) NOT NULL,
    front_image_public_id VARCHAR(255) NOT NULL,
    back_image_url VARCHAR(500) NOT NULL,
    back_image_public_id VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    user_id UUID NOT NULL,
    CONSTRAINT fk_citizen_users FOREIGN KEY (user_id) REFERENCES users(id)
);
CREATE INDEX idx_citizen_identities_user_id ON citizen_identities (user_id);

CREATE TABLE station_feedbacks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v7(),
    content TEXT,
    rating INT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    customer_id UUID NOT NULL,
    station_id UUID NOT NULL,
    CONSTRAINT fk_feedback_users FOREIGN KEY (customer_id) REFERENCES users(id),
    CONSTRAINT fk_feedback_stations FOREIGN KEY (station_id) REFERENCES stations(id)
);
CREATE INDEX idx_station_feedbacks_customer_id ON station_feedbacks (customer_id);
CREATE INDEX idx_station_feedbacks_station_id ON station_feedbacks (station_id);

CREATE TABLE brands (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v7(),
    name VARCHAR(50) NOT NULL,
    description VARCHAR(255) NOT NULL,
    country VARCHAR(50) NOT NULL,
    founded_year INT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ
);

CREATE TABLE vehicle_segments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v7(),
    name VARCHAR(50) NOT NULL,
    description VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ
);

CREATE TABLE vehicle_models (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v7(),
    name VARCHAR(100) NOT NULL,
    description VARCHAR(255) NOT NULL,
    cost_per_day NUMERIC(10,2) NOT NULL,
    deposit_fee NUMERIC(10, 2) NOT NULL,
    reservation_fee NUMERIC(10, 2) NOT NULL,
    seating_capacity INT NOT NULL,
    number_of_airbags INT NOT NULL,
    motor_power NUMERIC(5,1) NOT NULL,
    battery_capacity NUMERIC(6,2) NOT NULL,
    eco_range_km NUMERIC(6,1) NOT NULL,
    sport_range_km NUMERIC(6,1) NOT NULL,
    image_url VARCHAR(500),
    image_public_id VARCHAR(255),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    brand_id UUID NOT NULL,
    segment_id UUID NOT NULL,
    CONSTRAINT fk_model_brands FOREIGN KEY (brand_id) REFERENCES brands(id),
    CONSTRAINT fk_model_segments FOREIGN KEY (segment_id) REFERENCES vehicle_segments(id)
);
CREATE INDEX idx_vehicle_models_brand_id ON vehicle_models (brand_id);
CREATE INDEX idx_vehicle_models_segment_id ON vehicle_models (segment_id);

CREATE TABLE model_images (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v7(),
    url VARCHAR(500) NOT NULL UNIQUE,
    public_id VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    model_id UUID NOT NULL,
    CONSTRAINT fk_model_images_vehicle_models FOREIGN KEY (model_id) REFERENCES vehicle_models(id)
);
CREATE INDEX idx_model_images_model_id ON model_images (model_id);

CREATE TABLE vehicle_components (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v7(),
    name VARCHAR(100) NOT NULL,
    description VARCHAR(255) NOT NULL,
    damage_fee NUMERIC(18, 2) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ
);

CREATE TABLE model_components (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v7(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    model_id UUID NOT NULL,
    component_id UUID NOT NULL,
    CONSTRAINT fk_model_components_vehicle_models FOREIGN KEY (model_id) REFERENCES vehicle_models(id),
    CONSTRAINT fk_model_components_vehicle_components FOREIGN KEY (component_id) REFERENCES vehicle_components(id)
);
CREATE INDEX idx_model_components_model_id ON model_components (model_id);
CREATE INDEX idx_model_components_component_id ON model_components (component_id);

CREATE TABLE vehicles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v7(),
    license_plate VARCHAR(15) NOT NULL UNIQUE,
    status INT NOT NULL DEFAULT 0, 
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    model_id UUID NOT NULL,
    station_id UUID NOT NULL,
    CONSTRAINT fk_vehicles_models FOREIGN KEY (model_id) REFERENCES vehicle_models(id),
    CONSTRAINT fk_vehicles_stations FOREIGN KEY (station_id) REFERENCES stations(id)
);
CREATE INDEX idx_vehicles_model_id ON vehicles (model_id);
CREATE INDEX idx_vehicles_station_id ON vehicles (station_id);

CREATE TABLE rental_contracts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v7(),
    description TEXT NOT NULL,
    notes VARCHAR(255),
    start_date TIMESTAMPTZ NOT NULL,
    actual_start_date TIMESTAMPTZ,
    end_date TIMESTAMPTZ NOT NULL,
    actual_end_date TIMESTAMPTZ,
    is_signed_by_staff BOOLEAN NOT NULL DEFAULT FALSE,
    is_signed_by_customer BOOLEAN NOT NULL DEFAULT FALSE,
    status INT NOT NULL DEFAULT 0, 
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    vehicle_id UUID,
    customer_id UUID NOT NULL,
    handover_staff_id UUID,
    return_staff_id UUID,
    station_id UUID NOT NULL,
    CONSTRAINT fk_rental_contracts_vehicles FOREIGN KEY (vehicle_id) REFERENCES vehicles(id),
    CONSTRAINT fk_rental_contracts_customers FOREIGN KEY (customer_id) REFERENCES users(id),
    CONSTRAINT fk_rental_contracts_handover_staffs FOREIGN KEY (handover_staff_id) REFERENCES staffs(user_id),
    CONSTRAINT fk_rental_contracts_return_staffs FOREIGN KEY (return_staff_id) REFERENCES staffs(user_id),
    CONSTRAINT fk_rental_contracts_stations FOREIGN KEY (station_id) REFERENCES stations(id)
);
CREATE INDEX idx_rental_contracts_vehicle_id ON rental_contracts (vehicle_id);
CREATE INDEX idx_rental_contracts_customer_id ON rental_contracts (customer_id);
CREATE INDEX idx_rental_contracts_handover_staff_id ON rental_contracts (handover_staff_id);
CREATE INDEX idx_rental_contracts_return_staff_id ON rental_contracts (return_staff_id);
CREATE INDEX idx_rental_contracts_station_id ON rental_contracts (station_id);

CREATE TABLE vehicle_checklists (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v7(),
    type INT NOT NULL DEFAULT 0,
    is_signed_by_staff BOOLEAN NOT NULL DEFAULT FALSE,
    is_signed_by_customer BOOLEAN NOT NULL DEFAULT FALSE,
    maintained_until TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    staff_id UUID NOT NULL,
    customer_id UUID NULL,
    vehicle_id UUID NOT NULL,
    contract_id UUID,
    CONSTRAINT fk_vehicle_checklists_staffs FOREIGN KEY (staff_id) REFERENCES staffs(user_id),
    CONSTRAINT fk_vehicle_checklists_users FOREIGN KEY (customer_id) REFERENCES users(id),
    CONSTRAINT fk_vehicle_checklists_vehicles FOREIGN KEY (vehicle_id) REFERENCES vehicles(id),
    CONSTRAINT fk_vehicle_checklists_contracts FOREIGN KEY (contract_id) REFERENCES rental_contracts(id)
);
CREATE INDEX idx_vehicle_checklists_staff_id ON vehicle_checklists (staff_id);
CREATE INDEX idx_vehicle_checklists_customer_id ON vehicle_checklists (customer_id);
CREATE INDEX idx_vehicle_checklists_vehicle_id ON vehicle_checklists (vehicle_id);
CREATE INDEX idx_vehicle_checklists_contract_id ON vehicle_checklists (contract_id);

CREATE TABLE vehicle_checklist_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v7(),
    notes VARCHAR(255),
    status INT NOT NULL DEFAULT 0, 
    image_url VARCHAR(500),
    image_public_id VARCHAR(255),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    component_id UUID NOT NULL,
    checklist_id UUID NOT NULL,
    CONSTRAINT fk_vehicle_checklist_items_components FOREIGN KEY (component_id) REFERENCES vehicle_components(id),
    CONSTRAINT fk_vehicle_checklist_items_checklists FOREIGN KEY (checklist_id) REFERENCES vehicle_checklists(id)
);
CREATE UNIQUE INDEX idx_vehicle_checklist_items_image_url ON vehicle_checklist_items (image_url) WHERE image_url IS NOT NULL;
CREATE INDEX idx_vehicle_checklist_items_component_id ON vehicle_checklist_items (component_id);
CREATE INDEX idx_vehicle_checklist_items_checklist_id ON vehicle_checklist_items (checklist_id);

CREATE TABLE invoices (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v7(),
    subtotal NUMERIC(10,2) NOT NULL,
    tax NUMERIC(10,2) NOT NULL,
    paid_amount NUMERIC(10,2),
    payment_method INT NOT NULL, 
    notes VARCHAR(255),
    status INT NOT NULL DEFAULT 0, 
    type INT NOT NULL DEFAULT 0,
    paid_at TIMESTAMPTZ,
    image_url VARCHAR(500),
    image_public_id VARCHAR(255),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    contract_id UUID NOT NULL,
    CONSTRAINT fk_invoices_contracts FOREIGN KEY (contract_id) REFERENCES rental_contracts(id)
);
CREATE INDEX idx_invoices_contract_id ON invoices (contract_id);

CREATE TABLE invoice_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v7(),
    description VARCHAR(100),
    quantity INT NOT NULL DEFAULT 1,
    unit_price NUMERIC(10,2) NOT NULL,
    type INT NOT NULL, 
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    invoice_id UUID NOT NULL,
    checklist_item_id UUID,
    CONSTRAINT fk_invoice_items_invoices FOREIGN KEY (invoice_id) REFERENCES invoices(id),
    CONSTRAINT fk_invoice_items_checklist_items FOREIGN KEY (checklist_item_id) REFERENCES vehicle_checklist_items(id)
);
CREATE INDEX idx_invoice_items_invoice_id ON invoice_items (invoice_id);
CREATE UNIQUE INDEX idx_invoice_items_checklist_item_id ON invoice_items (checklist_item_id) WHERE checklist_item_id IS NOT NULL;

CREATE TABLE deposits (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v7(),
    amount NUMERIC(10,2) NOT NULL,
    refunded_at TIMESTAMPTZ,
    status INT NOT NULL DEFAULT 0, 
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    invoice_id UUID NOT NULL UNIQUE,
    CONSTRAINT fk_deposits_invoices FOREIGN KEY (invoice_id) REFERENCES invoices(id)
);

CREATE TABLE dispatch_requests (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v7(),
    description TEXT,
    final_description TEXT,
    status INT NOT NULL DEFAULT 0, 
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    request_admin_id UUID NOT NULL,
    approved_admin_id UUID,
    from_station_id UUID,
    to_station_id UUID NOT NULL,
    CONSTRAINT fk_dispatch_requests_request_admins FOREIGN KEY (request_admin_id) REFERENCES staffs(user_id),
    CONSTRAINT fk_dispatch_requests_approved_admins FOREIGN KEY (approved_admin_id) REFERENCES staffs(user_id),
    CONSTRAINT fk_dispatch_requests_from_stations FOREIGN KEY (from_station_id) REFERENCES stations(id),
    CONSTRAINT fk_dispatch_requests_to_stations FOREIGN KEY (to_station_id) REFERENCES stations(id)
);
CREATE INDEX idx_dispatch_requests_request_admin_id ON dispatch_requests (request_admin_id);
CREATE INDEX idx_dispatch_requests_approved_admin_id ON dispatch_requests (approved_admin_id);
CREATE INDEX idx_dispatch_requests_from_station_id ON dispatch_requests (from_station_id);
CREATE INDEX idx_dispatch_requests_to_station_id ON dispatch_requests (to_station_id);

CREATE TABLE dispatch_request_staffs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v7(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    dispatch_request_id UUID NOT NULL,
    staff_id UUID NOT NULL,
    CONSTRAINT fk_dispatch_request_staffs_dispatch_requests FOREIGN KEY (dispatch_request_id) REFERENCES dispatch_requests(id),
    CONSTRAINT fk_dispatch_request_staffs_staffs FOREIGN KEY (staff_id) REFERENCES staffs(user_id)
);
CREATE INDEX idx_dispatch_request_staffs_dispatch_id ON dispatch_request_staffs (dispatch_request_id);
CREATE INDEX idx_dispatch_request_staffs_staff_id ON dispatch_request_staffs (staff_id);

CREATE TABLE dispatch_request_vehicles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v7(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    dispatch_request_id UUID NOT NULL,
    vehicle_id UUID NOT NULL,
    CONSTRAINT fk_dispatch_request_vehicles_dispatch_requests FOREIGN KEY (dispatch_request_id) REFERENCES dispatch_requests(id),
    CONSTRAINT fk_dispatch_request_vehicles_vehicles FOREIGN KEY (vehicle_id) REFERENCES vehicles(id)
);
CREATE INDEX idx_dispatch_request_vehicles_dispatch_id ON dispatch_request_vehicles (dispatch_request_id);
CREATE INDEX idx_dispatch_request_vehicles_vehicle_id ON dispatch_request_vehicles (vehicle_id);

CREATE TABLE business_variables (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v7(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    key INT NOT NULL,
    value NUMERIC(18,2) NOT NULL
);