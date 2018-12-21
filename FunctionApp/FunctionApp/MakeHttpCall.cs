using System;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Host;
using Microsoft.Extensions.Logging;
using Microsoft.ApplicationInsights.DataContracts;
using System.Collections.Generic;
using System.Net.Http;
using System.Threading.Tasks;
using System.Threading;
using Microsoft.ApplicationInsights;
using System.Diagnostics;

namespace FunctionApp
{
    public static class MakeHttpCall
    {
        private static readonly List<string> _urls = new List<string>()
        {
            "http://statefulservicetest.southcentralus.cloudapp.azure.com/",
            //"http://statefulservicetest.southcentralus.cloudapp.azure.com/Home/About",
            "http://statefulservicetest.southcentralus.cloudapp.azure.com:8000/",
            //"http://statefulservicetest.southcentralus.cloudapp.azure.com:8000/Home/About",
        };
        private static readonly int _randomDelayMaxValue = 500;
        private static readonly int _randomCallsMaxValue = 5;

        private static readonly string _instrumentationKey = "883178d4-c7f6-4806-8143-8c53dcc61108";
        private static readonly TelemetryClient _telemetryClient = new TelemetryClient(
            new Microsoft.ApplicationInsights.Extensibility.TelemetryConfiguration(_instrumentationKey));

        [FunctionName("MakeHttpCall")]
        public async static Task Run([TimerTrigger("0 */1 * * * *")]TimerInfo myTimer, ILogger log)
        {
            try
            {
                foreach (string url in _urls)
                {
                    int successCalls = 0;
                    double responseTime = 0;
                    int delay = new Random().Next(_randomDelayMaxValue);
                    int callCount = new Random().Next(_randomCallsMaxValue);

                    using (var client = new HttpClient())
                    {
                        for (int i = 0; i < callCount; i++)
                        {
                            log.LogInformation($"Call {i + 1}/{callCount} to Url {url}");

                            // Start watcher
                            var stopWatch = Stopwatch.StartNew();

                            // Make GET request
                            var response = await client.GetAsync(url);
                            long elapsed = stopWatch.ElapsedMilliseconds;

                            // Wait for randome delay
                            if (callCount > 1)
                                Thread.Sleep(delay);

                            // Track success calls
                            if (response.IsSuccessStatusCode)
                                successCalls++;

                            // Track response time milliseconds
                            responseTime += elapsed;
                        }
                    }

                    Dictionary<string, string> eventProperties = new Dictionary<string, string>()
                    {
                        { "Url", url },
                    };
                    Dictionary<string, double> eventMetrics = new Dictionary<string, double>()
                    {
                        { "TotalCalls", callCount },
                        { "AvgSuccess", successCalls / callCount },
                        { "AvgResponseTime", responseTime / callCount },
                    };

                    _telemetryClient.TrackEvent("HttpCall", eventProperties, eventMetrics);
                }
            }
            catch (Exception e)
            {
                _telemetryClient.TrackException(e);
            }
        }
    }
}
