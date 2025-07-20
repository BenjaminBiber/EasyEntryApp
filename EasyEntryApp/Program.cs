using Microsoft.AspNetCore.Components.Web;
using Microsoft.AspNetCore.Components.WebAssembly.Hosting;
using EasyEntryApp;
using EasyEntryLib.Services;
using MudBlazor.Services;

var builder = WebAssemblyHostBuilder.CreateDefault(args);
builder.RootComponents.Add<App>("#app");
builder.RootComponents.Add<HeadOutlet>("head::after");
builder.Services.AddMudServices();
builder.Services.AddScoped(sp => new HttpClient { BaseAddress = new Uri("https://easyentryapi.benjaminbiber.de") });
Console.WriteLine("http client created with base address: https://easyentryapi.benjaminbiber.de");
builder.Services.AddScoped<SettingService>();
builder.Services.AddScoped<DeviceGroupService>();
builder.Services.AddScoped<DeviceService>();

await builder.Build().RunAsync();
