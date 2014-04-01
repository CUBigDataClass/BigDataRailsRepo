define(['source/modules/directive'], function(directives) {
    'use strict';

    directives.directive('controls', function() {
        return {
            restrict: 'E',
            templateUrl: '/assets/source/templates/controls.html'
        };
    });
});
