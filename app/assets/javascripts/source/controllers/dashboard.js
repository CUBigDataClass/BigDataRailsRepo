define(['jquery', 'underscore', 'source/modules/controller'], function($, _, controllers) {
    'use strict';

    controllers.controller('Dashboard', function($scope) {

        $scope.data = {
            map: null,
            heatmap: null,
            heatmapOptions: null,
            mapOptions: null
        };

        $scope.controlDisplay = false,
                $scope.radius_stop = function(event, ui) {
            $scope.update_radius(ui.value);
        };

        $scope.update_radius = function(value) {
            if (!$scope.data.heatmap) {
                return;
            }

            $scope.data.heatmap.set('radius', value);
        };

        $scope.opacity_stop = function(event, ui) {
            $scope.update_opacity(ui.value);
        };

        $scope.update_opacity = function(value) {
            if (!$scope.data.heatmap) {
                return;
            }
            $scope.data.heatmap.set('opacity', value);
        };

        $scope.update_map_type = function(type) {
            var id = google.maps.MapTypeId.SATELLITE;
            switch (type) {
                case "road":
                    id = google.maps.MapTypeId.ROADMAP;
                    break;
                case "satellite":
                    id = google.maps.MapTypeId.SATELLITE;
                    break;
                case "hybrid":
                    id = google.maps.MapTypeId.HYBRID;
                    break;
                case "terrain":
                    id = google.maps.MapTypeId.TERRAIN;
                    break;
                default:
                    id = google.maps.MapTypeId.SATELLITE;
                    break;
            }
            $scope.data.mapOptions.mapTypeId = id;
            $scope.data.map.setOptions($scope.data.mapOptions);
        };

        $scope.query_params = [{include: true, input: ""}];

        $scope.init = function() {
            $scope.data.mapOptions = {
                zoom: 3,
                center: new google.maps.LatLng(39.7392, -104.9847),
                mapTypeId: google.maps.MapTypeId.SATELLITE,
                streetViewControl: false,
                mapTypeControl: false,
                zoomControlOptions: {
                    position: google.maps.ControlPosition.RIGHT_TOP,
                },
                panControlOptions: {
                    position: google.maps.ControlPosition.RIGHT_TOP,
                },
            };
            $scope.data.heatmapOptions = {
                radius: 20,
                opacity: 0.8,
                dissipating: true
            };
        };

        $scope.toggle_controls = function() {
            if ($scope.controlDisplay) {
                $("#controls").animate({
                    'margin-left': '-=400px'
                }, 1000, function() {
                });
            } else {
                $("#controls").animate({
                    'margin-left': '+=400px'
                }, 1000, function() {
                });
            }

            $scope.controlDisplay = !$scope.controlDisplay;
        };

        $scope.toggle_input_type = function(index) {
            $scope.query_params[index].include = !$scope.query_params[index].include;
        };

        $scope.add_query_param = function() {
            $scope.query_params.push({include: true, input: ""});
        };

        $scope.remove_query_param = function(index) {
            $scope.query_params.splice(index, 1);
        };

        $scope.submit_query = function() {
            //submit query goes here.
        };

        $scope.setup_new_map = function() {
            if (!($scope.data.elem && $scope.data.mapOptions)) {
                return;
            }
            $scope.data.map = new google.maps.Map($scope.data.elem, $scope.data.mapOptions);
        };

        $scope.toggleHeatmap = function() {
            if (!($scope.data.heatmap && $scope.data.map)) {
                return;
            }

            $scope.data.heatmap.setMap($scope.data.heatmap.getMap() ? null : $scope.data.map);
        };

        $scope.update_heatmap = function(ops) {
            if (!$scope.data.map) {
                return;
            }
            if (!$scope.data.heatmap) {
                $scope.data.heatmap = new google.maps.visualization.HeatmapLayer({
                    map: $scope.data.map
                });
            }
            $scope.data.heatmap.setValues(ops);
        };

        $scope.update_data = function(data) {
            if ($scope.data.heatmapOptions.data) {
                $scope.data.heatmapOptions.data.clear();
            }
            $scope.data.heatmapOptions.data = data;
        };

        $scope.get_data_interval = function() {
            if ($scope.dataInterval) {
                clearInterval($scope.dataInterval);
                $scope.dataInterval = null;
            } else {
                $scope.dataInterval = setInterval(function() {
                    $scope.get_data()
                }, 10000); //10 seconds
            }

        };

        $scope.get_data = function() {
            $.ajax({
                type: 'GET',
                url: '/twitter/lat_lon_sample.json',
                //url: '/assets/source/mock_data/mock_points.json', //Use this for testing when twitter isn't working
                success: function(parsedData) {

                    var coordArr = Array();
                    for (var i in parsedData) {
                        coordArr[i] = new google.maps.LatLng(parsedData[i][0], parsedData[i][1]);
                    }

                    $scope.update_data(new google.maps.MVCArray(coordArr));
                    $scope.update_heatmap($scope.data.heatmapOptions);
                }
            });
        };
    });
});
