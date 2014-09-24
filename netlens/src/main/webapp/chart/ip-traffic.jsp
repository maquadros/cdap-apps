<!--
Copyright © 2014 Cask Data, Inc.

Licensed under the Apache License, Version 2.0 (the "License"); you may not
use this file except in compliance with the License. You may obtain a copy of
the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
License for the specific language governing permissions and limitations under
the License.
-->

<div id="traffic" style="width: 100%; height: 100%"></div>

<script type="text/javascript">
    $(function() {
        reloadTrafficChart();
    });

    function reloadTrafficChart() {
        drawTrafficChart();
        setTimeout(function() {
            reloadTrafficChart();
        }, 5000);
    }

    function drawTrafficChart() {
        var fact = JSON.parse(decodeURIComponent('<%= request.getParameter("fact") %>'));
        var src = fact.dimensions.src;
        // todo: hack: we should not know here format of the key
        var key = '3src' + src.length + src;
        var startTs = Date.now() - 5000 * 120;
        var endTs = Date.now();
        $.post( "proxy/v2/apps/Netlens/procedures/CountersProcedure/methods/counts",
                        "{startTs:" + startTs + ", endTs:" + endTs + ", key:" + key + "}")
                .done(function( data ) {
                    points = JSON.parse(JSON.parse(data));
                    renderTrafficChart(points);

                })
                .fail( function(xhr, textStatus, errorThrown) {
                    $('#traffic').html("<div class='server_error''>Failed to get data from server<div>");
                })
    }

    function renderTrafficChart(points) {
        var data = [];
        points.forEach(function(point){
            data.push(point.value);
        });

        $('#traffic').highcharts({

            chart: {
                animation: false,
                type: 'line'
            },

            legend: {
                enabled: false
            },

            plotOptions: {
                series: {
                    animation: false,
                    marker: {
                        enabled: false
                    }
                }
            },

            title: {
                text: 'Outbound Traffic'
            },

            xAxis: {
                type: 'datetime'
            },

            yAxis: {
                title: '',
                min: 0
            },

            tooltip: {
                headerFormat: '<b>{series.name}</b><br />',
                pointFormat: '{point.y}'
            },

            series: [{
                data: data,
                pointInterval: 5000,
                pointStart: points[0].ts
            }]
        });
    };

</script>