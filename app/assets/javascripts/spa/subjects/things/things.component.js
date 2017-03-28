(function() {
    "use strict";

    angular
        .module("spa.subjects")
        .component("sdThingEditor", {
            templateUrl: thingEditorTemplateUrl,
            controller: ThingEditorController,
            bindings: {
                authz: "<"
            }
        })
        .component("sdThingSelector", {
            templateUrl: thingSelectorTemplateUrl,
            controller: ThingSelectorController,
            bindings: {
                authz: "<"
            }
        });


    thingEditorTemplateUrl.$inject = ["spa.config.APP_CONFIG"];
    function thingEditorTemplateUrl(APP_CONFIG) {
        return APP_CONFIG.thing_editor_html;
    }
    thingSelectorTemplateUrl.$inject = ["spa.config.APP_CONFIG"];
    function thingSelectorTemplateUrl(APP_CONFIG) {
        return APP_CONFIG.thing_selector_html;
    }

    ThingEditorController.$inject = ["$scope",
        "$state",
        "$stateParams",
        "spa.subjects.Thing",
        "spa.subjects.ThingImage",
        "$q",
        "spa.authz.Authz"];
    function ThingEditorController($scope, $state, $stateParams, Thing, ThingImage, $q, Authz) {
        var vm=this;
        vm.create = create;
        vm.clear  = clear;
        vm.update  = update;
        vm.remove  = remove;
        vm.haveDirtyLinks = haveDirtyLinks;

        vm.$onInit = function() {
            console.log("ThingEditorController",$scope);

            $scope.$watch(function () { return Authz.getAuthorizedUserId(); }, function () {
                if ($stateParams.id) {
                    // reload($stateParams.id);
                    $scope.$watch(function () { return vm.authz.authenticated; }, function () { reload($stateParams.id); });
                } else {
                    newResource();
                }
            });
        };

        //////////////
        function newResource() {
            vm.item = new Thing();
            return vm.item;
        }

        function reload (thingId) {
            var itemId = thingId ? thingId : vm.item.id;
            vm.images = ThingImage.query({ thing_id: itemId });
            vm.item = Thing.get({ id: itemId });
            vm.images.$promise.then(function () {
               angular.forEach(vm.images, function (ti) {
                   ti.originalPriority = ti.priority;
               });
            });

            $q.all([vm.item.$promise, vm.images.$promise]).catch(handleError);
        }

        function haveDirtyLinks () {
            for (var i = 0; vm.images && i < vm.images.length; i++) {
                var ti = vm.images[i];

                if (ti.toRemove || ti.originalPriority != ti.priority) {
                    return true;
                }
            }

            return false;
        }

        function create() {
            $scope.thingform.$setPristine();
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
            $scope.thingform.$setPristine();
            vm.item.errors = null;
            var update = vm.item.$update();
            updateImageLinks(update);
        }

        function updateImageLinks (promise) {
            var promises = [];

            if (promise) promises.push(promise);

            angular.forEach(vm.images, function (ti) {
                if (ti.toRemove) {
                    promises.push(ti.$remove());
                } else if (ti.originalPriority != ti.priority) {
                    promises.push(ti.$update());
                }
            });

            $q.all(promises).then(function (response) {
                $scope.thingform.$setPristine();
                reload();
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

    ThingSelectorController.$inject = ["$scope",
        "$stateParams",
        "spa.subjects.Thing",
        "spa.authz.Authz"];
    function ThingSelectorController($scope, $stateParams, Thing, Authz) {
        var vm=this;

        vm.$onInit = function() {
            console.log("ThingSelectorController",$scope);

            $scope.$watch(function () { return Authz.getAuthorizedUserId(); }, function () {
                if (!$stateParams.id) {
                    vm.items = Thing.query();
                }
            });
        };
    }
})();