namespace Application.Dtos.Common.Response
{
    public class PageResult<T>
    {
        public IEnumerable<T> Items { get; set; }
        public int PageNumber { get; set; }
        public int PageSize { get; set; }
        public int Total { get; set; }
        public int TotalPages => (int)Math.Ceiling((double)Total / PageSize);

        public PageResult(IEnumerable<T> items, int pageNumber, int pageSize, int total)
        {
            Items = items;
            PageNumber = pageNumber;
            PageSize = pageSize;
            Total = total;
        }
    }
}