define(['jquery', 'underscore', 'source/modules/controller'], function($, _, controllers) {
    'use strict';

    controllers.controller('Dashboard', function($scope) {

        $scope.data = {
            map: null,
            heatmap: null,
            heatmapOptions: null,
            mapOptions: null
        };

        $scope.refresh_rates = [
            {active: true, rate: 0},
            {active: false, rate: 10},
            {active: false, rate: 30},
            {active: false, rate: 60},
            {active: false, rate: 120},
        ];

        $scope.map_types = [
            {type: 'Road', active: false},
            {type: 'Satellite', active: true},
            {type: 'Hybrid', active: false},
            {type: 'Terrain', active: false}
        ];

        $scope.result_sizes = [
            {active: true, size: 10},
            {active: false, size: 100},
            {active: false, size: 1000},
            {active: false, size: 10000}
        ];

        $scope.query_params = [{include: true, input: ""}];

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
                case "Road":
                    id = google.maps.MapTypeId.ROADMAP;
                    break;
                case "Satellite":
                    id = google.maps.MapTypeId.SATELLITE;
                    break;
                case "Hybrid":
                    id = google.maps.MapTypeId.HYBRID;
                    break;
                case "Terrain":
                    id = google.maps.MapTypeId.TERRAIN;
                    break;
                default:
                    id = google.maps.MapTypeId.SATELLITE;
                    break;
            }
            _.each($scope.map_types, function(map){
                if(map.type == type){
                    map.active = true;
                } else {
                    map.active = false;
                };
            });
            $scope.data.mapOptions.mapTypeId = id;
            $scope.data.map.setOptions($scope.data.mapOptions);
        };

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
                }, 500, function() {
                });
            } else {
                $("#controls").animate({
                    'margin-left': '+=400px'
                }, 500, function() {
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
            $scope.get_data();
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

        $scope.set_refresh = function(secs) {
            if ($scope.dataInterval) {
                clearInterval($scope.dataInterval);
                $scope.dataInterval = null;
            } else {
                $scope.get_data();
                if(secs !== 0){
                    $scope.dataInterval = setInterval(function() {
                        $scope.get_data();
                    }, secs*1000);
                }
            }
            _.each($scope.refresh_rates, function(rate){
                if(secs == rate){
                    rate.active = true;
                } else {
                    rate.active = false;
                }
            });

        };

        $scope.set_size = function(size){
            _.each($scope.result_sizes, function(s){
                if(s.size == parseInt(size)) {
                    s.active = true;
                } else {
                    s.active = false;
                }
            });
            $scope.get_data();
        };

        $scope.get_result_size = function() {
            for(var i = 0; i < $scope.result_sizes.length; i++){
                if($scope.result_sizes[i].active){
                    return $scope.result_sizes[i].size;
                }
            }
            return 10;
        }

        $scope.generate_query = function() {
            var str_query = "";
            for(var i = 0; i < $scope.query_params.length; i++){
                if($scope.query_params[i].input === ""){
                    continue;
                }
                if($scope.query_params[i].include){
                    str_query += "+text:*" + $scope.query_params[i].input + "* ";
                } else {
                    str_query += "-text:*" + $scope.query_params[i].input + "* ";
                }
            }

            if(str_query == ""){
                str_query = "*";
            }

            var query = {
                "query":
                    {"query_string":{
                        "query": str_query
                    }
                },
                "size": $scope.get_result_size()};

            return query;

        };

        $scope.get_data = function() {
            $.ajax({
                type: 'GET',
                data: {"query" : $scope.generate_query()},
        contentType: "application/json;charset=utf-8",
        dateType:'json',
                url: '/twitter/elasticsearch_query.json',
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
