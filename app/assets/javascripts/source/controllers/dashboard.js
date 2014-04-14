define(['jquery', 'underscore', 'source/modules/controller'], function($, _, controllers) {
    'use strict';

    controllers.controller('Dashboard', function($scope) {

        $scope.data = {
            map: null,
            pointarray: null,
            heatmap: null,
            mapOptions: null
        };
        
        $scope.query_params = [{include: true, input: ""}];

        $scope.init = function() {
            $scope.data.mapOptions = {
                zoom: 3,
                center: new google.maps.LatLng(39.7392, -104.9847),
                mapTypeId: google.maps.MapTypeId.SATELLITE
            };
        };
        
        $scope.toggle_input_type = function(index){
            $scope.query_params[index].include =  !$scope.query_params[index].include;
        };
        
        $scope.add_query_param = function(){
            $scope.query_params.push({include:true, input:""});
        };
        
        $scope.remove_query_param = function(index){
            $scope.query_params.splice(index, 1);
            console.log($scope.query_params);
        };
        
        $scope.submit_query = function(){
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

        $scope.changeGradient = function() {
            if (!$scope.data.heatmap) {
                return;
            }

            var gradient = [
                'rgba(0, 255, 255, 0)',
                'rgba(0, 255, 255, 1)',
                'rgba(0, 191, 255, 1)',
                'rgba(0, 127, 255, 1)',
                'rgba(0, 63, 255, 1)',
                'rgba(0, 0, 255, 1)',
                'rgba(0, 0, 223, 1)',
                'rgba(0, 0, 191, 1)',
                'rgba(0, 0, 159, 1)',
                'rgba(0, 0, 127, 1)',
                'rgba(63, 0, 91, 1)',
                'rgba(127, 0, 63, 1)',
                'rgba(191, 0, 31, 1)',
                'rgba(255, 0, 0, 1)'
            ];
            $scope.data.heatmap.set('gradient', $scope.data.heatmap.get('gradient') ? null : gradient);
        };

        $scope.changeRadius = function() {
            if (!$scope.data.heatmap) {
                return;
            }

            $scope.data.heatmap.set('radius', $scope.data.heatmap.get('radius') === 20 ? 50 : 20);
        };

        $scope.changeOpacity = function() {
            if (!$scope.data.heatmap) {
                return;
            }

            $scope.data.heatmap.set('opacity', $scope.data.heatmap.get('opacity') ? null : 0.2);
        };

        $scope.get_data = function() {
            $.ajax({
                type: 'GET',
                //url: '/twitter/lat_lon_sample.json',
                url: '/assets/source/mock_data/mock_points.json', //Use this for testing when twitter isn't working
                success: function(parsedData) {

                    var coordArr = Array();
                    for (var i in parsedData) {
                        coordArr[i] = new google.maps.LatLng(parsedData[i][0], parsedData[i][1]);
                    }
                    
                    $scope.data.pointArray = new google.maps.MVCArray(coordArr);
                    $scope.data.heatmap = new google.maps.visualization.HeatmapLayer({
                        data: $scope.data.pointArray,
                        radius: 20
                    });

                    $scope.$emit('update_map');
                }
            });
        };
    });
});
