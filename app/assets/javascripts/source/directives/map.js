define(['source/modules/directive'], function(directives) {
    'use strict';

    directives.directive('map', function() {
        return {
            restrict: 'E',
            templateUrl: '/assets/source/templates/map.html',
            link: function(scope) {
                scope.$onRootScope('update_map', function(event, message) {
                    scope.data.heatmap.setMap(scope.data.map);
                    scope.$emit('map_updated');
                });
                scope.get_data();
                scope.data.elem = document.getElementById('map-canvas');
                scope.setup_new_map();
            }
        };
    });
});
