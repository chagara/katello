/**
 * Copyright 2013 Red Hat, Inc.
 *
 * This software is licensed to you under the GNU General Public
 * License as published by the Free Software Foundation; either version
 * 2 of the License (GPLv2) or (at your option) any later version.
 * There is NO WARRANTY for this software, express or implied,
 * including the implied warranties of MERCHANTABILITY,
 * NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
 * have received a copy of GPLv2 along with this software; if not, see
 * http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
 */

/**
 * @ngdoc object
 * @name  Bastion.systems.controller:SystemEventsController
 *
 * @requires $scope
 * @requires System
 * @requires Nutupane
 *
 * @description
 *   Provides the functionality for the system events list pane.
 */
angular.module('Bastion.systems').controller('SystemEventsController',
    ['$scope', 'System', 'Nutupane',
    function($scope, System, Nutupane) {
        var params,eventsNutupane;

        params = {
            'id'   :            $scope.$stateParams.systemId,
            'offset':           0,
            'sort_by':          'start_time',
            'sort_order':       'DESC',
            'paged':            true
        };

        eventsNutupane = new Nutupane(System, params, 'tasks');
        eventsNutupane.table.search = function() {
            eventsNutupane.table.resource.offset = 0;
            eventsNutupane.table.rows = [];

            if (!eventsNutupane.table.working) {
                eventsNutupane.query();
            }
        };

        $scope.eventsTable = eventsNutupane.table;
        $scope.eventsTable.openEventInfo = function(event) {
            $scope.transitionTo('systems.details.events.details', {eventId:event.id});
        };

    }
]);