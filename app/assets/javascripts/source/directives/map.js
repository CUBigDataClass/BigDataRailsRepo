define(['source/modules/directive'], function(directives) {
    'use strict';

    directives.directive('map', function() {
        return {
            restrict: 'E',
            templateUrl: '/assets/source/templates/map.html',
            link: function(scope) {
                scope.data.elem = document.getElementById('map-canvas');
                scope.setup_new_map();
                scope.get_data();
            }
        };
    });
});
