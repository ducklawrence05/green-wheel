using Domain.Commons;
using System;
using System.Collections.Generic;

namespace Domain.Entities;

public partial class User : SorfDeletedEntity, IEntity
{
    public Guid Id { get; set; }

    public string FirstName { get; set; } = null!;

    public string LastName { get; set; } = null!;

    public string? Email { get; set; }

    public string? Password { get; set; }

    public string? Phone { get; set; }

    public bool IsGoogleLinked { get; set; }

    public int? Sex { get; set; }

    public DateTimeOffset? DateOfBirth { get; set; }

    public string? AvatarUrl { get; set; }

    public string? AvatarPublicId { get; set; }

    public DateTimeOffset CreatedAt { get; set; }

    public DateTimeOffset UpdatedAt { get; set; }

    public Guid RoleId { get; set; }

    public virtual CitizenIdentity? CitizenIdentity { get; set; }

    public virtual DriverLicense? DriverLicense { get; set; }

    public virtual ICollection<RefreshToken> RefreshTokens { get; set; } = new List<RefreshToken>();

    public virtual ICollection<RentalContract> RentalContracts { get; set; } = new List<RentalContract>();

    public virtual Role Role { get; set; } = null!;

    public virtual Staff? Staff { get; set; }

    public virtual ICollection<StationFeedback> StationFeedbacks { get; set; } = new List<StationFeedback>();

    public virtual ICollection<Ticket> Tickets { get; set; } = new List<Ticket>();

    public virtual ICollection<VehicleChecklist> VehicleChecklists { get; set; } = new List<VehicleChecklist>();
}