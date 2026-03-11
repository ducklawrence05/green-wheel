/* ============================================================
    SECTION 2 — ROLES
============================================================ */
INSERT INTO roles (name, description) VALUES
  ('Admin', 'System administrator'),
  ('Staff', 'Station staff'),
  ('Customer', 'Vehicle customer'),
  ('SuperAdmin', 'Super Administrator');

/* ============================================================
    SECTION 3 — STATIONS
============================================================ */
INSERT INTO stations (name, address) VALUES
  ('Trạm A', '123 Quận 3, TP.HCM'),
  ('Trạm B', '456 Quận 6, TP.HCM');

/* ============================================================
    SECTION 4 — USERS (BASE ADMINS / STAFFS / 1 CUSTOMER)
============================================================ */
INSERT INTO users (first_name, last_name, email, password, phone, sex, role_id)
VALUES
  ('Nguyễn', 'Admin A', 'adminA@greenwheel.vn',
   '$2a$12$CZ2ikjkipa7p8kDYJN6o7.90TIjpIsswYSMr3iGYJBQQyj8/cgU06', '0901111111', 0, (SELECT id FROM roles WHERE name='Admin' LIMIT 1)),
  ('Phạm', 'Admin B', 'adminB@greenwheel.vn',
   '$2a$12$CZ2ikjkipa7p8kDYJN6o7.90TIjpIsswYSMr3iGYJBQQyj8/cgU06', '0902222222', 1, (SELECT id FROM roles WHERE name='Admin' LIMIT 1)),
  ('Trần', 'Staff A', 'staffA@greenwheel.vn',
   '$2a$12$UnyAq2ckOtLYgpDQbNTTje5IPx9cbdTRPw5MB.sDg12OYjygBWJFa', '0902345678', 1, (SELECT id FROM roles WHERE name='Staff' LIMIT 1)),
  ('Trần', 'Staff B', 'staffB@greenwheel.vn',
   '$2a$12$UnyAq2ckOtLYgpDQbNTTje5IPx9cbdTRPw5MB.sDg12OYjygBWJFa', '0902345670', 1, (SELECT id FROM roles WHERE name='Staff' LIMIT 1)),
  ('Lê', 'Customer', 'customer@greenwheel.vn',
   '$2a$12$EF0KCPRK/mIt16yJtjCL1u/R5K0NXE7Mu9Q0s1WLX.iNOVrNEtXYe', '0909999999', 0, (SELECT id FROM roles WHERE name='Customer' LIMIT 1)),
  ('Súp', 'Lơ', 'superAdmin@greenwheel.vn',
   '$2a$12$EF0KCPRK/mIt16yJtjCL1u/R5K0NXE7Mu9Q0s1WLX.iNOVrNEtXYe', '0909999997', 0, (SELECT id FROM roles WHERE name='SuperAdmin' LIMIT 1));

/* ============================================================
    SECTION 5 — STAFFS
============================================================ */
INSERT INTO staffs (user_id, station_id) VALUES
  ((SELECT id FROM users WHERE email='adminA@greenwheel.vn'), (SELECT id FROM stations WHERE name LIKE '%A%' LIMIT 1)),
  ((SELECT id FROM users WHERE email='adminB@greenwheel.vn'), (SELECT id FROM stations WHERE name LIKE '%B%' LIMIT 1)),
  ((SELECT id FROM users WHERE email='staffA@greenwheel.vn'), (SELECT id FROM stations WHERE name LIKE '%A%' LIMIT 1)),
  ((SELECT id FROM users WHERE email='staffB@greenwheel.vn'), (SELECT id FROM stations WHERE name LIKE '%B%' LIMIT 1));

/* ============================================================
    SECTION 6 — BRANDS
============================================================ */
INSERT INTO brands (name, description, country, founded_year) VALUES
  ('VinFast', 'Thương hiệu xe điện Việt Nam', 'Việt Nam', 2017);

/* ============================================================
    SECTION 7 — VEHICLE SEGMENTS
============================================================ */
INSERT INTO vehicle_segments (name, description) VALUES
  ('Compact', 'Xe nhỏ gọn cho đô thị'),
  ('SUV', 'Xe gầm cao thể thao đa dụng');

/* ============================================================
    SECTION 9 — VEHICLE COMPONENTS
============================================================ */
INSERT INTO vehicle_components (name, description, damage_fee) VALUES
  ('Động cơ điện', 'Bộ phận tạo công suất vận hành', 10000),
  ('Pin', 'Nguồn năng lượng cho xe', 10000),
  ('Hệ thống phanh', 'Tăng độ an toàn khi di chuyển', 10000),
  ('Nội thất', 'Ghế ngồi, màn hình, tiện ích nội thất', 10000);

/* ============================================================
    SECTION 10- VEHICLE MODELS & IMAGES & COMPONENTS
============================================================ */
DO $$
DECLARE
    v_brand UUID := (SELECT id FROM brands WHERE name='VinFast' LIMIT 1);
    v_segSUV UUID := (SELECT id FROM vehicle_segments WHERE name='SUV' LIMIT 1);
    v_segCompact UUID := (SELECT id FROM vehicle_segments WHERE name='Compact' LIMIT 1);
    mVF3 UUID := uuid_generate_v7();
    mVF5 UUID := uuid_generate_v7();
    mVF6 UUID := uuid_generate_v7();
    mVF7 UUID := uuid_generate_v7();
    mVF8 UUID := uuid_generate_v7();
BEGIN
    -- VF3
    INSERT INTO vehicle_models (id, name, description, cost_per_day, deposit_fee, seating_capacity, number_of_airbags, motor_power, battery_capacity, eco_range_km, sport_range_km, brand_id, segment_id, image_url, image_public_id, reservation_fee)
    VALUES (mVF3, 'VinFast VF 3', 'Mini EV', 8000, 5000, 4, 4, 50, 20, 210, 180, v_brand, v_segCompact, 'http://res.cloudinary.com/dsnnghkez/image/upload/v1763744812/models/b3112edf-b21b-448e-91f1-05206ba7a1e3/main/xxmh2cqwwdjfsgb4s1ul.jpg', 'models/b3112edf-b21b-448e-91f1-05206ba7a1e3/main/xxmh2cqwwdjfsgb4s1ul', 10000);

    -- VF5
    INSERT INTO vehicle_models (id, name, description, cost_per_day, deposit_fee, seating_capacity, number_of_airbags, motor_power, battery_capacity, eco_range_km, sport_range_km, brand_id, segment_id, image_url, image_public_id, reservation_fee)
    VALUES (mVF5, 'VinFast VF 5', 'Compact SUV điện hạng A', 11000, 8000, 5, 4, 70, 37, 300, 260, v_brand, v_segCompact, 'http://res.cloudinary.com/dsnnghkez/image/upload/v1762872756/models/28aa7e24-94f6-460c-82b9-fc1c8363662e/main/nguslcg6tdip8kenx07r.jpg', 'models/28aa7e24-94f6-460c-82b9-fc1c8363662e/main/nguslcg6tdip8kenx07r', 10000);

    -- VF6
    INSERT INTO vehicle_models (id, name, description, cost_per_day, deposit_fee, seating_capacity, number_of_airbags, motor_power, battery_capacity, eco_range_km, sport_range_km, brand_id, segment_id, image_url, image_public_id, reservation_fee)
    VALUES (mVF6, 'VinFast VF 6', 'EV C-Class', 14000, 12000, 5, 6, 150, 59, 380, 320, v_brand, v_segSUV, 'http://res.cloudinary.com/dsnnghkez/image/upload/v1763745120/models/e6130878-0854-4d66-8c25-cafd65035abd/main/ajtbxgtkws4q5inspwmy.jpg', 'models/e6130878-0854-4d66-8c25-cafd65035abd/main/ajtbxgtkws4q5inspwmy', 10000);

    -- VF7
    INSERT INTO vehicle_models (id, name, description, cost_per_day, deposit_fee, seating_capacity, number_of_airbags, motor_power, battery_capacity, eco_range_km, sport_range_km, brand_id, segment_id, image_url, image_public_id, reservation_fee)
    VALUES (mVF7, 'VinFast VF 7', 'EV D-Class', 17000, 14000, 5, 6, 180, 75, 420, 360, v_brand, v_segSUV, 'http://res.cloudinary.com/dsnnghkez/image/upload/v1762873454/models/21dc600f-367c-4b81-9d3b-11dc3b6a886a/main/ejl9qomhobnvwqhgccx4.jpg', 'models/21dc600f-367c-4b81-9d3b-11dc3b6a886a/main/ejl9qomhobnvwqhgccx4', 10000);

    -- VF8
    INSERT INTO vehicle_models (id, name, description, cost_per_day, deposit_fee, seating_capacity, number_of_airbags, motor_power, battery_capacity, eco_range_km, sport_range_km, brand_id, segment_id, image_url, image_public_id, reservation_fee)
    VALUES (mVF8, 'VinFast VF 8', 'EV E-Class', 20000, 16000, 5, 8, 220, 87, 480, 410, v_brand, v_segSUV, 'http://res.cloudinary.com/dsnnghkez/image/upload/v1762873366/models/57294a88-6a43-432d-8f0d-370bd1f9fe40/main/jyk2vtm2bsys7rotodbu.jpg', 'models/57294a88-6a43-432d-8f0d-370bd1f9fe40/main/jyk2vtm2bsys7rotodbu', 10000);

    -- IMAGES VF8
    INSERT INTO model_images (url, public_id, model_id) VALUES
    ('http://res.cloudinary.com/dk5pwoag4/image/upload/v1762178014/models/a00b3abd-c55d-4fc0-8be5-1ac002894533/gallery/eqc49vffpwnk6jy1bqet.jpg', 'models/57294a88-6a43-432d-8f0d-370bd1f9fe40/gallery/gptnvechnciutdm0qazz', mVF8),
    ('http://res.cloudinary.com/dsnnghkez/image/upload/v1762873372/models/57294a88-6a43-432d-8f0d-370bd1f9fe40/gallery/pnymkeyuflbdp24h5uf6.jpg', 'models/57294a88-6a43-432d-8f0d-370bd1f9fe40/gallery/pnymkeyuflbdp24h5uf6', mVF8),
    ('http://res.cloudinary.com/dsnnghkez/image/upload/v1762873371/models/57294a88-6a43-432d-8f0d-370bd1f9fe40/gallery/slebbhl6qo8p68luuju8.jpg', 'models/57294a88-6a43-432d-8f0d-370bd1f9fe40/gallery/slebbhl6qo8p68luuju8', mVF8),
    ('http://res.cloudinary.com/dsnnghkez/image/upload/v1762873369/models/57294a88-6a43-432d-8f0d-370bd1f9fe40/gallery/tqjxy3kfjwjfzxuin9y4.jpg', 'models/57294a88-6a43-432d-8f0d-370bd1f9fe40/gallery/tqjxy3kfjwjfzxuin9y4', mVF8);

    -- IMAGES VF5, VF7, VF3, VF6 ...
    INSERT INTO model_images (url, public_id, model_id) VALUES
    ('http://res.cloudinary.com/dsnnghkez/image/upload/v1762872762/models/28aa7e24-94f6-460c-82b9-fc1c8363662e/gallery/sgijrmiz7ubwjkoj52py.jpg', 'models/28aa7e24-94f6-460c-82b9-fc1c8363662e/gallery/sgijrmiz7ubwjkoj52py', mVF5),
    ('http://res.cloudinary.com/dsnnghkez/image/upload/v1762872758/models/28aa7e24-94f6-460c-82b9-fc1c8363662e/gallery/p1xx6j52pmcghqbcid01.jpg', 'models/28aa7e24-94f6-460c-82b9-fc1c8363662e/gallery/p1xx6j52pmcghqbcid01', mVF5),
    ('http://res.cloudinary.com/dsnnghkez/image/upload/v1762872760/models/28aa7e24-94f6-460c-82b9-fc1c8363662e/gallery/mukgqmbp7ysvifzbn7yh.jpg', 'models/28aa7e24-94f6-460c-82b9-fc1c8363662e/gallery/mukgqmbp7ysvifzbn7yh', mVF5),
    ('http://res.cloudinary.com/dsnnghkez/image/upload/v1762873464/models/21dc600f-367c-4b81-9d3b-11dc3b6a886a/gallery/svxtrm5dtr6ahvvvieak.jpg', 'models/21dc600f-367c-4b81-9d3b-11dc3b6a886a/gallery/svxtrm5dtr6ahvvvieak', mVF7),
    ('http://res.cloudinary.com/dsnnghkez/image/upload/v1762873460/models/21dc600f-367c-4b81-9d3b-11dc3b6a886a/gallery/mmr7wimleqpmcezwyb4s.jpg', 'models/21dc600f-367c-4b81-9d3b-11dc3b6a886a/gallery/mmr7wimleqpmcezwyb4s', mVF7),
    ('http://res.cloudinary.com/dsnnghkez/image/upload/v1762873465/models/21dc600f-367c-4b81-9d3b-11dc3b6a886a/gallery/ybjliyfx0ec9wgfyoijk.jpg', 'models/21dc600f-367c-4b81-9d3b-11dc3b6a886a/gallery/ybjliyfx0ec9wgfyoijk', mVF7),
    ('http://res.cloudinary.com/dsnnghkez/image/upload/v1762873458/models/21dc600f-367c-4b81-9d3b-11dc3b6a886a/gallery/n3lm6ipstseackbwz8al.jpg', 'models/21dc600f-367c-4b81-9d3b-11dc3b6a886a/gallery/n3lm6ipstseackbwz8al', mVF7),
    ('http://res.cloudinary.com/dsnnghkez/image/upload/v1763744816/models/b3112edf-b21b-448e-91f1-05206ba7a1e3/gallery/lvhoncqb41ddrdp29axj.jpg', 'models/b3112edf-b21b-448e-91f1-05206ba7a1e3/gallery/lvhoncqb41ddrdp29axj', mVF3),
    ('http://res.cloudinary.com/dsnnghkez/image/upload/v1763744814/models/b3112edf-b21b-448e-91f1-05206ba7a1e3/gallery/njqvhepokoukrpre5kdg.jpg', 'models/b3112edf-b21b-448e-91f1-05206ba7a1e3/gallery/njqvhepokoukrpre5kdg', mVF3),
    ('http://res.cloudinary.com/dsnnghkez/image/upload/v1763744815/models/b3112edf-b21b-448e-91f1-05206ba7a1e3/gallery/leqascx1ckxmyazc7dkz.jpg', 'models/b3112edf-b21b-448e-91f1-05206ba7a1e3/gallery/leqascx1ckxmyazc7dkz', mVF3),
    ('http://res.cloudinary.com/dsnnghkez/image/upload/v1763745124/models/e6130878-0854-4d66-8c25-cafd65035abd/gallery/cxrhlsecwy8fcizk4enq.jpg', 'models/e6130878-0854-4d66-8c25-cafd65035abd/gallery/cxrhlsecwy8fcizk4enq', mVF6),
    ('http://res.cloudinary.com/dsnnghkez/image/upload/v1763745127/models/e6130878-0854-4d66-8c25-cafd65035abd/gallery/sr99c3gbqtw5pidsplzc.jpg', 'models/e6130878-0854-4d66-8c25-cafd65035abd/gallery/sr99c3gbqtw5pidsplzc', mVF6),
    ('http://res.cloudinary.com/dsnnghkez/image/upload/v1763745122/models/e6130878-0854-4d66-8c25-cafd65035abd/gallery/jvcbi7vxkod6kogtjhxz.jpg', 'models/e6130878-0854-4d66-8c25-cafd65035abd/gallery/jvcbi7vxkod6kogtjhxz', mVF6);

    -- MODEL COMPONENTS
    INSERT INTO model_components(model_id, component_id)
    SELECT mVF3, id FROM vehicle_components
    UNION ALL SELECT mVF5, id FROM vehicle_components
    UNION ALL SELECT mVF6, id FROM vehicle_components
    UNION ALL SELECT mVF7, id FROM vehicle_components
    UNION ALL SELECT mVF8, id FROM vehicle_components;

END $$;

/* ============================================================
    SECTION 11 — VEHICLES (ALL MODELS)
============================================================ */
DO $$
DECLARE
    sA UUID := (SELECT id FROM stations WHERE name LIKE '%A%' LIMIT 1);
    sB UUID := (SELECT id FROM stations WHERE name LIKE '%B%' LIMIT 1);
    mVF3 UUID := (SELECT id FROM vehicle_models WHERE name='VinFast VF 3' LIMIT 1);
    mVF5 UUID := (SELECT id FROM vehicle_models WHERE name='VinFast VF 5' LIMIT 1);
    mVF6 UUID := (SELECT id FROM vehicle_models WHERE name='VinFast VF 6' LIMIT 1);
    mVF7 UUID := (SELECT id FROM vehicle_models WHERE name='VinFast VF 7' LIMIT 1);
    mVF8 UUID := (SELECT id FROM vehicle_models WHERE name='VinFast VF 8' LIMIT 1);
BEGIN
    INSERT INTO vehicles (license_plate, status, model_id, station_id) VALUES
    ('51C-100.01',0,mVF3,sA), ('51C-100.02',0,mVF3,sA), ('51C-100.03',0,mVF3,sB), ('51C-100.04',0,mVF3,sA), ('51C-100.05',0,mVF3,sB),
    ('51C-200.01',0,mVF5,sA), ('51C-200.02',0,mVF5,sA), ('51C-200.03',0,mVF5,sB), ('51C-200.04',0,mVF5,sA), ('51C-200.05',0,mVF5,sB),
    ('51C-300.01',0,mVF6,sA), ('51C-300.02',0,mVF6,sA), ('51C-300.03',0,mVF6,sB), ('51C-300.04',0,mVF6,sA), ('51C-300.05',0,mVF6,sB),
    ('51C-700.01',0,mVF7,sA), ('51C-700.02',0,mVF7,sA), ('51C-700.03',0,mVF7,sB), ('51C-700.04',0,mVF7,sA), ('51C-700.05',0,mVF7,sB),
    ('51C-800.01',0,mVF8,sA);
END $$;

/* ============================================================
    SECTION 12 — CANCELLED CONTRACTS
============================================================ */
DO $$
DECLARE
    customerUser UUID := (SELECT id FROM users WHERE email='customer@greenwheel.vn' LIMIT 1);
    handoverStaff UUID := (SELECT id FROM users WHERE email='staffA@greenwheel.vn' LIMIT 1);
    vehA UUID := (SELECT id FROM vehicles WHERE license_plate='51C-100.01' LIMIT 1);
    vehB UUID := (SELECT id FROM vehicles WHERE license_plate='51C-200.01' LIMIT 1);
    vehC UUID := (SELECT id FROM vehicles WHERE license_plate='51C-300.01' LIMIT 1);
    stationA UUID := (SELECT id FROM stations WHERE name LIKE '%A%' LIMIT 1);
    stationB UUID := (SELECT id FROM stations WHERE name LIKE '%B%' LIMIT 1);
BEGIN
    INSERT INTO rental_contracts (description, notes, start_date, end_date, status, is_signed_by_staff, is_signed_by_customer, vehicle_id, customer_id, handover_staff_id, return_staff_id, station_id)
    VALUES
    ('Hợp đồng A1', 'Huỷ do thay đổi kế hoạch', NOW() - INTERVAL '5 days', NOW() - INTERVAL '3 days', 5, false, false, vehA, customerUser, handoverStaff, handoverStaff, stationA),
    ('Hợp đồng B1', 'Huỷ vì không cung cấp đủ giấy tờ', NOW() - INTERVAL '4 days', NOW() - INTERVAL '2 days', 5, false, false, vehB, customerUser, handoverStaff, handoverStaff, stationB),
    ('Hợp đồng A2', 'Huỷ do không thanh toán tiền cọc', NOW() - INTERVAL '2 days', NOW() - INTERVAL '1 days', 5, false, false, vehC, customerUser, handoverStaff, handoverStaff, stationA);
END $$;

/* ============================================================
    SECTION 13 — BUSINESS VARIABLES
============================================================ */
INSERT INTO business_variables (key, value) VALUES
(0, 10000),  -- LateReturnFee
(1, 10000),  -- CleaningFee
(2, 0.1),    -- BaseVAT
(3, 1),      -- MaxLateReturnHours
(4, 10),     -- BufferDay
(5, 10);     -- RefundCreationDelayDays

/* ============================================================
    SECTION 14 & 15 — PROCEDURES
============================================================ */
CREATE OR REPLACE PROCEDURE __seed_create_invoices(
    p_contract_id UUID,
    p_reservation_paid BOOLEAN,
    p_handover_paid BOOLEAN
) LANGUAGE plpgsql AS $$
DECLARE
    v_vehicle_id UUID;
    v_model_id UUID;
    v_deposit NUMERIC(10,2);
    v_reservation_subtotal NUMERIC(10,2) := 3000.00;
    v_handover_subtotal NUMERIC(10,2) := 5000.00;
    v_reservation_tax_rate NUMERIC(10,2) := 0.00;
    v_handover_tax_rate NUMERIC(10,2) := 0.10;
    
    v_reservation_invoice_id UUID := uuid_generate_v7();
    v_reservation_paid_amount NUMERIC(10,2);
    
    v_handover_invoice_id UUID := uuid_generate_v7();
    v_handover_paid_amount NUMERIC(10,2);
BEGIN
    SELECT vehicle_id INTO v_vehicle_id FROM rental_contracts WHERE id = p_contract_id;
    SELECT model_id INTO v_model_id FROM vehicles WHERE id = v_vehicle_id;
    SELECT deposit_fee INTO v_deposit FROM vehicle_models WHERE id = v_model_id;

    IF p_reservation_paid THEN v_reservation_paid_amount := v_reservation_subtotal; ELSE v_reservation_paid_amount := NULL; END IF;

    -- RESERVATION
    INSERT INTO invoices (id, subtotal, tax, paid_amount, payment_method, notes, status, type, paid_at, contract_id)
    VALUES (v_reservation_invoice_id, v_reservation_subtotal, v_reservation_tax_rate, v_reservation_paid_amount, 0, 'Reservation invoice', CASE WHEN p_reservation_paid THEN 1 ELSE 0 END, 0, CASE WHEN p_reservation_paid THEN NOW() ELSE NULL END, p_contract_id);

    -- HANDOVER
    IF p_handover_paid THEN v_handover_paid_amount := v_handover_subtotal * (1 + v_handover_tax_rate); ELSE v_handover_paid_amount := NULL; END IF;

    INSERT INTO invoices (id, subtotal, tax, paid_amount, payment_method, notes, status, type, paid_at, contract_id)
    VALUES (v_handover_invoice_id, v_handover_subtotal, v_handover_tax_rate, v_handover_paid_amount, 0, 'Handover invoice', CASE WHEN p_handover_paid THEN 1 ELSE 0 END, 1, CASE WHEN p_handover_paid THEN NOW() ELSE NULL END, p_contract_id);

    -- DEPOSIT
    INSERT INTO deposits (amount, refunded_at, status, invoice_id)
    VALUES (v_deposit, NULL, CASE WHEN p_handover_paid THEN 1 ELSE 0 END, v_handover_invoice_id);
END $$;

CREATE OR REPLACE PROCEDURE __seed_create_handover_checklist(
    p_staff_id UUID,
    p_customer_id UUID,
    p_vehicle_id UUID,
    p_contract_id UUID
) LANGUAGE plpgsql AS $$
DECLARE
    v_chk UUID := uuid_generate_v7();
BEGIN
    INSERT INTO vehicle_checklists (id, type, is_signed_by_staff, is_signed_by_customer, staff_id, customer_id, vehicle_id, contract_id)
    VALUES (v_chk, 1, true, true, p_staff_id, p_customer_id, p_vehicle_id, p_contract_id);

    INSERT INTO vehicle_checklist_items (status, component_id, checklist_id)
    SELECT 0, id, v_chk FROM vehicle_components;
END $$;

/* ============================================================
    SECTION 16 — EXTRA CUSTOMER USERS (13 USERS)
============================================================ */
DO $$
DECLARE
    cRole UUID := (SELECT id FROM roles WHERE name='Customer' LIMIT 1);
    u13 UUID := uuid_generate_v7();
BEGIN
    INSERT INTO users (first_name,last_name,email,password,phone,sex,role_id) VALUES
    ('Duy','Case 1 Main','lehoangduy23092005@gmail.com','$2a$12$EF0KCPRK/mIt16yJtjCL1u/R5K0NXE7Mu9Q0s1WLX.iNOVrNEtXYe','0903000001',0,cRole),
    ('Duy','Case 1 Sub','lehoangduy23905@gmail.com','$2a$12$EF0KCPRK/mIt16yJtjCL1u/R5K0NXE7Mu9Q0s1WLX.iNOVrNEtXYe','0903000002',0,cRole),
    ('Duy','Case 2 Main','lehoangduy20102005@gmail.com','$2a$12$EF0KCPRK/mIt16yJtjCL1u/R5K0NXE7Mu9Q0s1WLX.iNOVrNEtXYe','0903000003',0,cRole),
    ('Duy','Case 2 Sub','hoangduyle.work@gmail.com','$2a$12$EF0KCPRK/mIt16yJtjCL1u/R5K0NXE7Mu9Q0s1WLX.iNOVrNEtXYe','0903000004',0,cRole),
    ('Huy','Case 3 Main','huyngse183274@fpt.edu.vn','$2a$12$EF0KCPRK/mIt16yJtjCL1u/R5K0NXE7Mu9Q0s1WLX.iNOVrNEtXYe','0903000005',0,cRole),
    ('Huy','Case 3 Sub','ngogiahuy.work@gmail.com','$2a$12$EF0KCPRK/mIt16yJtjCL1u/R5K0NXE7Mu9Q0s1WLX.iNOVrNEtXYe','0903000006',0,cRole),
    ('Đức','Case 4 Main','duck05gaming@gmai.com','$2a$12$EF0KCPRK/mIt16yJtjCL1u/R5K0NXE7Mu9Q0s1WLX.iNOVrNEtXYe','0903000007',0,cRole),
    ('Đức','Case 4 Sub','duck.test.dev.05@gmail.com','$2a$12$EF0KCPRK/mIt16yJtjCL1u/R5K0NXE7Mu9Q0s1WLX.iNOVrNEtXYe','0903000008',0,cRole),
    ('Huy','Cleaning','Huycungbaobinh@gmail.com','$2a$12$EF0KCPRK/mIt16yJtjCL1u/R5K0NXE7Mu9Q0s1WLX.iNOVrNEtXYe','0903000009',0,cRole),
    ('Huy','Warning','Nguyenquanghuy14022005@gmail.com','$2a$12$EF0KCPRK/mIt16yJtjCL1u/R5K0NXE7Mu9Q0s1WLX.iNOVrNEtXYe','0903000010',0,cRole),
    ('Huy','Free 1','Quanghuynguyen14022005@gmail.com','$2a$12$EF0KCPRK/mIt16yJtjCL1u/R5K0NXE7Mu9Q0s1WLX.iNOVrNEtXYe','0903000011',0,cRole),
    ('Huy','Free 2','Huyquangnguyen14022005@gmail.com','$2a$12$EF0KCPRK/mIt16yJtjCL1u/R5K0NXE7Mu9Q0s1WLX.iNOVrNEtXYe','0903000012',0,cRole);

    -- Insert Huytradecoin with predefined UUID to link identities
    INSERT INTO users (id, first_name,last_name,email,password,phone,sex,role_id) VALUES
    (u13, 'Huy','Free 3','Huytradecoin@gmail.com','$2a$12$EF0KCPRK/mIt16yJtjCL1u/R5K0NXE7Mu9Q0s1WLX.iNOVrNEtXYe','0903000013',0,cRole);

    INSERT INTO citizen_identities (number, full_name, nationality, sex, date_of_birth, expires_at, front_image_url, front_image_public_id, back_image_url, back_image_public_id, user_id)
    VALUES ('019199887766', 'Phạm Thị Diệu Thu', 'Việt Nam', 1, '2004-01-01T00:00:00+00:00', '2030-01-07T00:00:00+00:00', 'http://res.cloudinary.com/dsnnghkez/image/upload/v1763651082/citizen-ids-front/mxoxxmampq83dzauec1m.jpg', 'citizen-ids-front/mxoxxmampq83dzauec1m', 'http://res.cloudinary.com/dsnnghkez/image/upload/v1763651084/citizen-ids-back/fsryrk9jblhf8bvayyan.jpg', 'citizen-ids-back/fsryrk9jblhf8bvayyan', u13);

    INSERT INTO driver_licenses (number, class, full_name, nationality, sex, date_of_birth, expires_at, front_image_url, front_image_public_id, back_image_url, back_image_public_id, user_id)
    VALUES ('011859806M', 1, 'Nguyễn Hoàng Minh Nguyệt', 'Việt Nam', 1, '2004-10-29T00:00:00+00:00', '2015-09-28T00:00:00+00:00', 'http://res.cloudinary.com/dsnnghkez/image/upload/v1763651104/driver-license-front/bijuyhg1nmgv20jfg6om.jpg', 'driver-license-front/bijuyhg1nmgv20jfg6om', 'http://res.cloudinary.com/dsnnghkez/image/upload/v1763651108/driver-license-back/iutqovdh8hljw2ddxs6q.jpg', 'driver-license-back/iutqovdh8hljw2ddxs6q', u13);
END $$;

/* ============================================================
   SECTION 17 — COMPLETED CONTRACTS FOR JAN–NOV 2025
============================================================ */
DO $$
DECLARE
    v_custRole UUID;
    v_staffDefault UUID;
    v_stationA_MAIN UUID;
    u_arr UUID[];
    v_arr UUID[];
    m_arr UUID[];
    v_uCount INT;
    v_vCount INT;
    v_i INT := 1;
    v_month INT := 1;
    v_u UUID; v_v UUID; v_modelId UUID;
    v_depositAmount NUMERIC;
    v_startDate TIMESTAMPTZ; v_endDate TIMESTAMPTZ; v_createdAt TIMESTAMPTZ;
    v_contractId UUID;
    v_invRes UUID; v_resSubtotal NUMERIC := 100000;
    v_invHand UUID; v_basePrice NUMERIC := 300000; v_vat NUMERIC := 300000 * 0.1;
    v_invReturn UUID; v_returnSubtotal NUMERIC := 50000;
    v_invRefund UUID;
BEGIN
    SELECT id INTO v_custRole FROM roles WHERE name='Customer' LIMIT 1;
    SELECT user_id INTO v_staffDefault FROM staffs LIMIT 1;
    SELECT id INTO v_stationA_MAIN FROM stations ORDER BY name LIMIT 1;

    SELECT array_agg(id) INTO u_arr FROM users WHERE role_id = v_custRole;
    SELECT array_agg(id) INTO v_arr FROM vehicles;
    SELECT array_agg(model_id) INTO m_arr FROM vehicles;

    v_uCount := array_length(u_arr, 1);
    v_vCount := array_length(v_arr, 1);

    WHILE v_month <= 11 LOOP
        v_u := u_arr[v_i];
        v_v := v_arr[v_i];
        v_modelId := m_arr[v_i];

        SELECT deposit_fee INTO v_depositAmount FROM vehicle_models WHERE id = v_modelId;

        v_startDate := CAST('2025-' || v_month || '-10 08:00:00+07' AS TIMESTAMPTZ);
        v_endDate := v_startDate + INTERVAL '3 days';
        v_createdAt := CAST('2025-' || v_month || '-10 09:00:00+07' AS TIMESTAMPTZ);

        v_contractId := uuid_generate_v7();

        INSERT INTO rental_contracts (id, description, notes, start_date, end_date, status, is_signed_by_staff, is_signed_by_customer, vehicle_id, customer_id, handover_staff_id, station_id, actual_start_date, actual_end_date, created_at, updated_at)
        VALUES (v_contractId, CONCAT('Completed Contract Month ', v_month), 'Seed data for statistics', v_startDate, v_endDate, 4, true, true, v_v, v_u, v_staffDefault, v_stationA_MAIN, v_startDate, v_endDate, v_createdAt, v_createdAt);

        -- RES INVOICE
        v_invRes := uuid_generate_v7();
        INSERT INTO invoices (id, contract_id, type, status, subtotal, tax, payment_method, paid_amount, notes, created_at, updated_at)
        VALUES (v_invRes, v_contractId, 0, 1, v_resSubtotal, 0, 0, v_resSubtotal, 'Reservation invoice', v_createdAt, v_createdAt);
        INSERT INTO invoice_items (id, description, quantity, unit_price, type, created_at, updated_at, invoice_id)
        VALUES (uuid_generate_v7(), 'Reservation Fee', 1, v_resSubtotal, 0, v_createdAt, v_createdAt, v_invRes);

        -- HANDOVER INVOICE
        v_invHand := uuid_generate_v7();
        INSERT INTO invoices (id, contract_id, type, status, subtotal, tax, payment_method, paid_amount, notes, created_at, updated_at)
        VALUES (v_invHand, v_contractId, 1, 1, v_basePrice, 0.1, 0, v_basePrice + v_vat, 'Handover invoice', v_createdAt, v_createdAt);
        INSERT INTO invoice_items (id, description, quantity, unit_price, type, created_at, updated_at, invoice_id)
        VALUES (uuid_generate_v7(), 'Handover Base Rental', 1, v_basePrice, 0, v_createdAt, v_createdAt, v_invHand);

        INSERT INTO deposits (id, invoice_id, amount, status, created_at, updated_at)
        VALUES (uuid_generate_v7(), v_invHand, v_depositAmount, 1, v_createdAt, v_createdAt);

        -- RETURN INVOICE
        v_invReturn := uuid_generate_v7();
        INSERT INTO invoices (id, contract_id, type, status, subtotal, tax, payment_method, paid_amount, notes, created_at, updated_at)
        VALUES (v_invReturn, v_contractId, 2, 1, v_returnSubtotal, 0, 0, v_returnSubtotal, 'Return invoice', v_createdAt, v_createdAt);
        INSERT INTO invoice_items (id, description, quantity, unit_price, type, created_at, updated_at, invoice_id)
        VALUES (uuid_generate_v7(), 'Cleaning Fee', 1, v_returnSubtotal, 3, v_createdAt, v_createdAt, v_invReturn);

        -- REFUND INVOICE
        v_invRefund := uuid_generate_v7();
        INSERT INTO invoices (id, contract_id, type, status, subtotal, tax, payment_method, paid_amount, notes, created_at, updated_at)
        VALUES (v_invRefund, v_contractId, 3, 1, v_depositAmount, 0, 0, v_depositAmount, 'Refund invoice', v_createdAt, v_createdAt);
        INSERT INTO invoice_items (id, description, quantity, unit_price, type, created_at, updated_at, invoice_id)
        VALUES (uuid_generate_v7(), 'Deposit Refund', 1, v_depositAmount, 5, v_createdAt, v_createdAt, v_invRefund);

        v_i := v_i + 1;
        IF v_i > v_uCount THEN v_i := 1; END IF;
        IF v_i > v_vCount THEN v_i := 1; END IF;
        
        v_month := v_month + 1;
    END LOOP;

    -- Updates
    UPDATE invoices SET subtotal = 100000 WHERE id IN (SELECT id FROM invoices WHERE contract_id IN (SELECT id FROM rental_contracts WHERE status = 4) AND EXTRACT(MONTH FROM created_at) = 1);
    UPDATE invoices SET subtotal = 130000 WHERE id IN (SELECT id FROM invoices WHERE contract_id IN (SELECT id FROM rental_contracts WHERE status = 4) AND EXTRACT(MONTH FROM created_at) = 2);
    UPDATE invoices SET subtotal = 80000  WHERE id IN (SELECT id FROM invoices WHERE contract_id IN (SELECT id FROM rental_contracts WHERE status = 4) AND EXTRACT(MONTH FROM created_at) = 3);
    UPDATE invoices SET subtotal = 180000 WHERE id IN (SELECT id FROM invoices WHERE contract_id IN (SELECT id FROM rental_contracts WHERE status = 4) AND EXTRACT(MONTH FROM created_at) = 4);
    UPDATE invoices SET subtotal = 140000 WHERE id IN (SELECT id FROM invoices WHERE contract_id IN (SELECT id FROM rental_contracts WHERE status = 4) AND EXTRACT(MONTH FROM created_at) = 5);
    UPDATE invoices SET subtotal = 60000  WHERE id IN (SELECT id FROM invoices WHERE contract_id IN (SELECT id FROM rental_contracts WHERE status = 4) AND EXTRACT(MONTH FROM created_at) = 6);
    UPDATE invoices SET subtotal = 200000 WHERE id IN (SELECT id FROM invoices WHERE contract_id IN (SELECT id FROM rental_contracts WHERE status = 4) AND EXTRACT(MONTH FROM created_at) = 7);
    UPDATE invoices SET subtotal = 120000 WHERE id IN (SELECT id FROM invoices WHERE contract_id IN (SELECT id FROM rental_contracts WHERE status = 4) AND EXTRACT(MONTH FROM created_at) = 8);
    UPDATE invoices SET subtotal = 100000 WHERE id IN (SELECT id FROM invoices WHERE contract_id IN (SELECT id FROM rental_contracts WHERE status = 4) AND EXTRACT(MONTH FROM created_at) = 9);
    UPDATE invoices SET subtotal = 170000 WHERE id IN (SELECT id FROM invoices WHERE contract_id IN (SELECT id FROM rental_contracts WHERE status = 4) AND EXTRACT(MONTH FROM created_at) = 10);
    UPDATE invoices SET subtotal = 130000 WHERE id IN (SELECT id FROM invoices WHERE contract_id IN (SELECT id FROM rental_contracts WHERE status = 4) AND EXTRACT(MONTH FROM created_at) = 11);
END $$;

/* ============================================================
    SECTION 18 — MAIL SCENARIOS (A → F)
============================================================ */
DO $$
DECLARE
    u1 UUID := (SELECT id FROM users WHERE email='lehoangduy23092005@gmail.com');
    u2 UUID := (SELECT id FROM users WHERE email='lehoangduy23905@gmail.com');
    u3 UUID := (SELECT id FROM users WHERE email='lehoangduy20102005@gmail.com');
    u4 UUID := (SELECT id FROM users WHERE email='hoangduyle.work@gmail.com');
    u5 UUID := (SELECT id FROM users WHERE email='huyngse183274@fpt.edu.vn');
    u6 UUID := (SELECT id FROM users WHERE email='ngogiahuy.work@gmail.com');
    u7 UUID := (SELECT id FROM users WHERE email='duck05gaming@gmai.com');
    u8 UUID := (SELECT id FROM users WHERE email='duck.test.dev.05@gmail.com');
    u9 UUID := (SELECT id FROM users WHERE email='Huycungbaobinh@gmail.com');
    u10 UUID := (SELECT id FROM users WHERE email='Nguyenquanghuy14022005@gmail.com');
    
    vVF3 UUID := (SELECT id FROM vehicles WHERE license_plate='51C-100.01');
    vVF5 UUID := (SELECT id FROM vehicles WHERE license_plate='51C-200.01');
    vVF6 UUID := (SELECT id FROM vehicles WHERE license_plate='51C-300.01');
    vVF7A UUID := (SELECT id FROM vehicles WHERE license_plate='51C-700.01');
    vVF7B UUID := (SELECT id FROM vehicles WHERE license_plate='51C-700.02');
    vVF8 UUID := (SELECT id FROM vehicles WHERE license_plate='51C-800.01');
    
    staff UUID := (SELECT id FROM users WHERE email='staffA@greenwheel.vn');
    sA UUID := (SELECT id FROM stations WHERE name LIKE '%A%' LIMIT 1);

    cA1 UUID := uuid_generate_v7(); cA2 UUID := uuid_generate_v7();
    cB1 UUID := uuid_generate_v7(); cB2 UUID := uuid_generate_v7();
    cC1 UUID := uuid_generate_v7(); cC2 UUID := uuid_generate_v7();
    cD1 UUID := uuid_generate_v7(); cD2 UUID := uuid_generate_v7();
    cE UUID := uuid_generate_v7();
    cF UUID := uuid_generate_v7();
BEGIN
    -- Scenario A
    INSERT INTO rental_contracts (id,description,start_date,end_date,status,is_signed_by_staff,is_signed_by_customer,vehicle_id,customer_id,handover_staff_id,station_id)
    VALUES
    (cA1,'PP VF3 U1','2025-11-20T00:00:00+07:00','2025-12-01T00:00:00+07:00',1,false,false,vVF3,u1,staff,sA),
    (cA2,'PP VF3 U2','2025-11-20T00:00:00+07:00','2025-12-01T00:00:00+07:00',1,false,false,vVF3,u2,staff,sA);
    CALL __seed_create_invoices(cA1,false,false);
    CALL __seed_create_invoices(cA2,false,false);

    -- Scenario B
    INSERT INTO rental_contracts (id,description,start_date,end_date,status,is_signed_by_staff,is_signed_by_customer,vehicle_id,customer_id,handover_staff_id,station_id,actual_start_date)
    VALUES
    (cB1,'Active VF5 U3','2025-11-01T00:00:00+07:00','2025-11-20T11:00:00+07:00',2,true,true,vVF5,u3,staff,sA,'2025-11-01T00:00:00+07:00'),
    (cB2,'PP VF5 U4','2025-12-01T00:00:00+07:00','2025-12-03T00:00:00+07:00',1,false,false,vVF5,u4,staff,sA,NULL);
    CALL __seed_create_invoices(cB1,true,true);
    CALL __seed_create_invoices(cB2,false,false);
    CALL __seed_create_handover_checklist(staff,u3,vVF5,cB1);
    UPDATE vehicles SET status=2 WHERE id=vVF5;

    -- Scenario C
    INSERT INTO rental_contracts (id,description,start_date,end_date,status,is_signed_by_staff,is_signed_by_customer,vehicle_id,customer_id,handover_staff_id,station_id,actual_start_date)
    VALUES
    (cC1,'Active VF6 U5','2025-11-01T00:00:00+07:00','2025-11-20T11:00:00+07:00',2,true,true,vVF6,u5,staff,sA,'2025-11-01T00:00:00+07:00'),
    (cC2,'Active VF6 U6','2025-12-01T00:00:00+07:00','2025-12-03T00:00:00+07:00',2,true,true,vVF6,u6,staff,sA,NULL);
    CALL __seed_create_invoices(cC1,true,true);
    CALL __seed_create_invoices(cC2,true,true);
    CALL __seed_create_handover_checklist(staff,u5,vVF6,cC1);
    UPDATE vehicles SET status=2 WHERE id=vVF6;

    -- Scenario D
    INSERT INTO rental_contracts (id,description,start_date,end_date,status,is_signed_by_staff,is_signed_by_customer,vehicle_id,customer_id,handover_staff_id,station_id,actual_start_date)
    VALUES
    (cD1,'Active VF8 U7','2025-11-01T00:00:00+07:00','2025-11-20T11:00:00+07:00',2,true,true,vVF8,u7,staff,sA,'2025-11-01T00:00:00+07:00'),
    (cD2,'Active VF8 U8','2025-12-01T00:00:00+07:00','2025-12-03T00:00:00+07:00',2,true,true,vVF8,u8,staff,sA,NULL);
    CALL __seed_create_invoices(cD1,true,true);
    CALL __seed_create_invoices(cD2,true,true);
    CALL __seed_create_handover_checklist(staff,u7,vVF8,cD1);
    UPDATE vehicles SET status=2 WHERE id=vVF8;

    -- Scenario E
    INSERT INTO rental_contracts (id,description,start_date,end_date,status,is_signed_by_staff,is_signed_by_customer,vehicle_id,customer_id,handover_staff_id,station_id)
    VALUES (cE,'Active VF7A U9','2025-10-29T00:00:00+07:00','2025-11-20T09:00:00+07:00',2,true,true,vVF7A,u9,staff,sA);
    CALL __seed_create_invoices(cE,true,true);
    UPDATE vehicles SET status=2 WHERE id=vVF7A;

    -- Scenario F
    INSERT INTO rental_contracts (id,description,start_date,end_date,status,is_signed_by_staff,is_signed_by_customer,vehicle_id,customer_id,handover_staff_id,station_id,actual_start_date)
    VALUES (cF,'Active VF7B U10','2025-10-29T00:00:00+07:00','2025-11-20T09:00:00+07:00',2,true,true,vVF7B,u10,staff,sA,'2025-10-29T00:00:00+07:00');
    CALL __seed_create_invoices(cF,true,true);
    UPDATE vehicles SET status=2 WHERE id=vVF7B;
END $$;

/* ============================================================
    SECTION 19 — DROP TEMP PROCEDURES
============================================================ */
DROP PROCEDURE IF EXISTS __seed_create_invoices;
DROP PROCEDURE IF EXISTS __seed_create_handover_checklist;

/* ============================================================
    SECTION 20 — SEEDING FEEDBACK
============================================================ */
INSERT INTO station_feedbacks (content, rating, station_id, customer_id) VALUES
  ('Nhân viên tên Duy đẹp trai', 5, (SELECT id FROM stations WHERE name LIKE '%A%' LIMIT 1), (SELECT id FROM users WHERE email='huyngse183274@fpt.edu.vn')),
  ('Nhân viên tên Phúc khó chịu với khách hàng', 3, (SELECT id FROM stations WHERE name LIKE '%A%' LIMIT 1), (SELECT id FROM users WHERE email='ngogiahuy.work@gmail.com')),
  ('Nhân viên tên Phúc rất là thái độ với khách hàng, không bao giờ ghé lại trạm này', 1, (SELECT id FROM stations WHERE name LIKE '%A%' LIMIT 1), (SELECT id FROM users WHERE email='Quanghuynguyen14022005@gmail.com')),
  ('Nhân viên nhiệt tình, cụ thể là anh Duy', 5, (SELECT id FROM stations WHERE name LIKE '%A%' LIMIT 1), (SELECT id FROM users WHERE email='huyngse183274@fpt.edu.vn')),
  ('Sao chỉ cho đánh giá tới 5 sao vậy, 5 sao cho trạm, 10 sao cho anh Duy', 5, (SELECT id FROM stations WHERE name LIKE '%A%' LIMIT 1), (SELECT id FROM users WHERE email='duck05gaming@gmai.com')),
  ('Nhân viên nhiệt tình, xe quá oke', 5, (SELECT id FROM stations WHERE name LIKE '%A%' LIMIT 1), (SELECT id FROM users WHERE email='Nguyenquanghuy14022005@gmail.com')),
  ('Xe chạy êm, nhân viên xử lí nhiệt tình', 5, (SELECT id FROM stations WHERE name LIKE '%B%' LIMIT 1), (SELECT id FROM users WHERE email='Quanghuynguyen14022005@gmail.com')),
  ('Nhân viên nhiệt tình, xe chạy êm', 5, (SELECT id FROM stations WHERE name LIKE '%B%' LIMIT 1), (SELECT id FROM users WHERE email='Huyquangnguyen14022005@gmail.com')),
  ('Xe mới, chạy rất thích', 5, (SELECT id FROM stations WHERE name LIKE '%B%' LIMIT 1), (SELECT id FROM users WHERE email='Huytradecoin@gmail.com')),
  ('Nhân viên nhiệt tình, xử lí cụ thể rõ ràng', 5, (SELECT id FROM stations WHERE name LIKE '%B%' LIMIT 1), (SELECT id FROM users WHERE email='duck.test.dev.05@gmail.com')),
  ('Cảm ơn trạm vì đã đến', 5, (SELECT id FROM stations WHERE name LIKE '%B%' LIMIT 1), (SELECT id FROM users WHERE email='ngogiahuy.work@gmail.com'));