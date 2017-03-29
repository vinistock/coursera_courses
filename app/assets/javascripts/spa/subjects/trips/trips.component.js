(function() {
    "use strict";

    angular
        .module("spa.subjects")
        .component("sdTripEditor", {
            templateUrl: tripEditorTemplateUrl,
            controller: TripEditorController,
            bindings: {
                authz: "<"
            },
            require: {
                tripsAuthz: "^sdTripsAuthz"
            }
        })
        .component("sdTripSelector", {
            templateUrl: tripSelectorTemplateUrl,
            controller: TripSelectorController,
            bindings: {
                authz: "<"
            }
        });


    tripEditorTemplateUrl.$inject = ["spa.config.APP_CONFIG"];
    function tripEditorTemplateUrl(APP_CONFIG) {
        return APP_CONFIG.trip_editor_html;
    }
    tripSelectorTemplateUrl.$inject = ["spa.config.APP_CONFIG"];
    function tripSelectorTemplateUrl(APP_CONFIG) {
        return APP_CONFIG.trip_selector_html;
    }

    TripEditorController.$inject = ["$scope",
        "$state",
        "$stateParams",
        "spa.subjects.Trip",
        "$q",
        "spa.authz.Authz",
        "spa.subjects.Image"];
    function TripEditorController($scope, $state, $stateParams, Trip, $q, Authz, Image) {
        var vm=this;
        vm.create = create;
        vm.clear  = clear;
        vm.update  = update;
        vm.remove  = remove;
        vm.postImage = postImage;
        vm.haveDirtyLinks = haveDirtyLinks;

        vm.$onInit = function() {
            console.log("TripEditorController",$scope);

            $scope.$watch(function () { return Authz.getAuthorizedUserId(); }, function () {
                if ($stateParams.id) {
                    $scope.$watch(function () { return vm.authz.authenticated; }, function () { reload($stateParams.id); });
                } else {
                    newResource();
                }
            });
        };

        //////////////
        function newResource() {
            vm.item = new Trip();
            vm.tripsAuthz.newItem(vm.item);
            return vm.item;
        }

        function reload (tripId) {
            var itemId = tripId ? tripId : vm.item.id;
            vm.item = Trip.get({ id: itemId });
            vm.tripsAuthz.newItem(vm.item);

            $q.all([vm.item.$promise]).catch(handleError);
        }

        function haveDirtyLinks () {
            for (var i = 0; vm.images && i < vm.images.length; i++) {
                var ti = vm.images[i];

                if (ti.toRemove) {
                    return true;
                }
            }

            return false;
        }

        function postImage () {
            var image = new Image({ caption: vm.new_image_caption, trip_id: vm.item.id });

            image.$save().then(function () {
                vm.new_image_caption = null;
                reload(vm.item.id);

            }, handleError);
        }

        function create() {
            $scope.tripform.$setPristine();
            vm.item.errors = null;
            vm.item.$save().then(
                function(){
                    $state.go(".",{id:vm.item.id});
                },
                handleError);
        }

        function clear() {
            newResource();
            $state.go(".",{id: null});
        }
        function update() {
            $scope.tripform.$setPristine();
            vm.item.errors = null;
            var update = vm.item.$update();
            updateImageLinks(update);
        }

        function updateImageLinks (promise) {
            var promises = [];

            if (promise) promises.push(promise);

            angular.forEach(vm.item.images, function (ti) {
                if (ti.toRemove) {
                    promises.push(Image.get({id: ti.id}).$promise.then(function (image) {
                        promises.push(image.$remove());
                    }));
                }
            });

            $q.all(promises).then(function (response) {
                $scope.tripform.$setPristine();
                reload(vm.item.id);
            }, handleError);
        }

        function remove() {
            vm.item.$remove().then(
                function(){
                    clear();
                },
                handleError);
        }

        function handleError(response) {
            if (response.data) {
                vm.item["errors"]=response.data.errors;
            }
            if (!vm.item.errors) {
                vm.item["errors"]={};
                vm.item["errors"]["full_messages"]=[response];
            }
        }
    }

    TripSelectorController.$inject = ["$scope",
        "$stateParams",
        "spa.subjects.Trip",
        "spa.authz.Authz"];
    function TripSelectorController($scope, $stateParams, Trip, Authz) {
        var vm=this;

        vm.$onInit = function() {
            console.log("TripSelectorController",$scope);

            $scope.$watch(function () { return Authz.getAuthorizedUserId(); }, function () {
                if (!$stateParams.id) {
                    vm.items = Trip.query();
                }
            });
        };
    }
})();
