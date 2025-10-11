using Domain.Commons;
using Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.ChangeTracking;

namespace Infrastructure.ApplicationDbContext
{
    public interface IGreenWheelDbContext
    {
        DbSet<Brand> Brands { get; set; }

        DbSet<CitizenIdentity> CitizenIdentities { get; set; }

        DbSet<Deposit> Deposits { get; set; }

        DbSet<DispatchRequest> DispatchRequests { get; set; }

        DbSet<DispatchRequestStaff> DispatchRequestStaffs { get; set; }

        DbSet<DispatchRequestVehicle> DispatchRequestVehicles { get; set; }

        DbSet<DriverLicense> DriverLicenses { get; set; }

        DbSet<Invoice> Invoices { get; set; }

        DbSet<InvoiceItem> InvoiceItems { get; set; }

        DbSet<ModelComponent> ModelComponents { get; set; }

        DbSet<ModelImage> ModelImages { get; set; }

        DbSet<RefreshToken> RefreshTokens { get; set; }

        DbSet<RentalContract> RentalContracts { get; set; }

        DbSet<Role> Roles { get; set; }

         DbSet<Staff> Staffs { get; set; }

        DbSet<Station> Stations { get; set; }

        DbSet<StationFeedback> StationFeedbacks { get; set; }

         DbSet<Ticket> Tickets { get; set; }

        DbSet<User> Users { get; set; }

        DbSet<Vehicle> Vehicles { get; set; }

        DbSet<VehicleChecklist> VehicleChecklists { get; set; }

        DbSet<VehicleChecklistItem> VehicleChecklistItems { get; set; }

        DbSet<VehicleComponent> VehicleComponents { get; set; }

        DbSet<VehicleModel> VehicleModels { get; set; }

        DbSet<VehicleSegment> VehicleSegments { get; set; }

        public DbSet<T> Set<T>() where T : class, IEntity;

        public EntityEntry<T> Entry<T>(T entity) where T : class;

        public int SaveChanges();

        public Task<int> SaveChangesAsync(CancellationToken cancellationToken = default);
    }
}