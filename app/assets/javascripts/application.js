require.config({

    paths: {
        'angular': 'lib/angular/angular.min',
        'ngRoute': 'lib/angular/angular-route.min',
        'ngResource': 'lib/angular/angular-resource.min',
        'jquery': 'lib/jquery/jquery',
        'underscore': 'lib/underscore/underscore.min',
        'text' : 'lib/require/text',
        'map-api': 'lib/map_api/map-api',
        'jquery-ui': 'lib/jquery/jquery-ui.min',
        'ui-slider': 'lib/angular/ui/slider'
    },

    shim: {
        'angular': {
            exports: 'angular'
        },
        'ngRoute': {
            deps: ['angular']
        },
        'ngResource': {
            deps: ['angular']
        },
        'underscore': {
            exports: '_'
        },
        'jquery-ui': {
            deps: ['jquery']
        },
        'ui-slider':{
            deps:['angular', 'jquery', 'jquery-ui']
        }
    }
});


define([ 'jquery', 'underscore', 'angular', 'app', 'router'], function ($, _, angular) {
    'use strict';

    $(document).ready(function(){
        angular.bootstrap(document, ['app']);
    });

});