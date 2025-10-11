using API.Filters;
using Application;
using Application.Abstractions;
using Application.Constants;
using Application.Dtos.VehicleChecklist.Request;
using Application.Dtos.VehicleModel.Respone;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace API.Controllers
{
    [Route("api/vehicle-checklists")]
    [ApiController]
    public class VehicleChecklistController : ControllerBase
    {
        private readonly IVehicleChecklistService _vehicleChecklistService;
        private readonly IChecklistItemImageService _imageService;

        public VehicleChecklistController(IVehicleChecklistService vehicleChecklistService, IChecklistItemImageService imageService)
        {
            _vehicleChecklistService = vehicleChecklistService;
            _imageService = imageService;
        }

        /*
         * status code
         * 200 success
         *
         */

        [HttpPost]
        [RoleAuthorize(RoleName.Staff)]
        public async Task<IActionResult> CreateVehicleChecklist(CreateVehicleChecklistReq req)
        {
            var staff = HttpContext.User;
            var vehicleCheckList = await _vehicleChecklistService.CreateVehicleChecklist(staff, req);
            return Ok(vehicleCheckList);
        }

        [HttpPut]
        [RoleAuthorize(RoleName.Staff)]
        public async Task<IActionResult> UpdateVehicleChecklist([FromBody] UpdateVehicleChecklistReq req)
        {
            await _vehicleChecklistService.UpdateVehicleChecklistAsync(req);
            return Ok();
        }

        [HttpGet("{id}")]
        [RoleAuthorize(RoleName.Staff)]
        public async Task<IActionResult> GetById(Guid id)
        {
            var checklistViewRes = await _vehicleChecklistService.GetByIdAsync(id);
            return Ok(checklistViewRes);
        }

        [HttpPost("image")]
        [RoleAuthorize(RoleName.Staff)]
        [Consumes("multipart/form-data")]
        [ApiExplorerSettings(IgnoreApi = true)]
        public async Task<IActionResult> UploadChecklistItemImage(Guid itemId, [FromForm(Name = "file")] IFormFile file)
        {
            var result = await _imageService.UploadChecklistItemImageAsync(itemId, file);
            return Ok(result);
        }

        [HttpDelete("image")]
        [RoleAuthorize(RoleName.Staff)]
        [ApiExplorerSettings(IgnoreApi = true)]
        public async Task<IActionResult> DeleteChecklistItemImage(Guid itemId)
        {
            var result = await _imageService.DeleteChecklistItemImageAsync(itemId);
            return Ok(result);
        }
    }
}