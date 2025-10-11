using API.Filters;
using Application.Abstractions;
using Application.Constants;
using Application.Dtos.VehicleModel.Request;
using Application.Dtos.VehicleModel.Respone;
using Microsoft.AspNetCore.Mvc;

namespace API.Controllers
{
    [ApiController]
    [RoleAuthorize(["Staff", "Admin"])]
    [Route("api/vehicle-models/{modelId:guid}")]
    public class ModelImagesController : ControllerBase
    {
        private readonly IModelImageService _modelImageService;
        private readonly IVehicleModelService _vehicleMBodelService;

        public ModelImagesController(
            IModelImageService modelImageService,
            IVehicleModelService vehicleModelService)
        {
            _modelImageService = modelImageService;
            _vehicleMBodelService = vehicleModelService;
        }

        // ---------- SUB-IMAGES (gallery) ----------
        [HttpPost("sub-images")]
        [Consumes("multipart/form-data")]
        [ApiExplorerSettings(IgnoreApi = true)]
        public async Task<IActionResult> UploadSubImages([FromRoute] Guid modelId, [FromForm] UploadModelImagesReq req)
        {
            var res = await _modelImageService.UploadModelImagesAsync(modelId, req.Files);
            return Ok(new { data = res, message = Message.CloudinaryMessage.UploadSuccess });
        }

        [HttpDelete("sub-images")]
        [Consumes("application/json")]
        [ApiExplorerSettings(IgnoreApi = true)]
        public async Task<IActionResult> DeleteSubImages([FromRoute] Guid modelId, [FromBody] DeleteModelImagesReq req)
        {
            await _modelImageService.DeleteModelImagesAsync(modelId, req.ImageIds);
            return Ok(new { message = Message.CloudinaryMessage.DeleteSuccess });
        }

        // ---------- MAIN IMAGE ----------
        [HttpPost("main-image")]
        [Consumes("multipart/form-data")]
        [ApiExplorerSettings(IgnoreApi = true)]
        public async Task<IActionResult> UploadMainImage([FromRoute] Guid modelId, [FromForm(Name = "file")] IFormFile file)
        {
            var imageUrl = await _vehicleMBodelService.UploadMainImageAsync(modelId, file);
            return Ok(new { data = new { modelId, imageUrl }, message = Message.CloudinaryMessage.UploadSuccess });
        }

        [HttpDelete("main-image")]
        [ApiExplorerSettings(IgnoreApi = true)]
        public async Task<IActionResult> DeleteMainImage([FromRoute] Guid modelId)
        {
            await _vehicleMBodelService.DeleteMainImageAsync(modelId);
            return Ok(new { message = Message.CloudinaryMessage.DeleteSuccess });
        }

        // ---------- MAIN + GALLERY ----------
        [HttpPost("images")]
        [Consumes("multipart/form-data")]
        [ApiExplorerSettings(IgnoreApi = true)]
        public async Task<IActionResult> UploadAllImages([FromRoute] Guid modelId, [FromForm] UploadModelImagesReq req)
        {
            var (mainImage, galleryImages) = await _modelImageService.UploadAllModelImagesAsync(modelId, req.Files);
            return Ok(new { data = new { main = mainImage, gallery = galleryImages }, message = Message.CloudinaryMessage.UploadSuccess });
        }
    }
}