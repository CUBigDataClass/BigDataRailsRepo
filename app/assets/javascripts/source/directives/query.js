define(['source/modules/directive'], function(directives) {
    'use strict';

    directives.directive('query', function() {
        return {
            restrict: 'E',
            templateUrl: '/assets/source/templates/query.html'
        };
    });
});
