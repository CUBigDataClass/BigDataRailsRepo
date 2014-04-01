define(['angular', 
'ngRoute', 
'ngResource', 
'source/controllers/index', 
'source/directives/index', 
'source/filters/index', 
'source/services/index'],
    function (angular) {
        'use strict';

        var app = angular.module('app', [ 'app.controllers', 'app.directives', 'app.filters', 'app.services', 'ngRoute', 'ngResource']);

        return app;

    });
