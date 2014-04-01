define(['./app'], function (app) {
    'use strict';
    return app.config(['$routeProvider', function ($routeProvider) {

        $routeProvider.when('/dashboard', {
            templateUrl: '/assets/source/partials/dashboard.html',
            controller: 'Dashboard'
        });

        $routeProvider.otherwise({
            redirectTo: '/dashboard'
        });
    }]);
});
