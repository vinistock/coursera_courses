(function () {
    "use strict";

    angular.module("spa.subjects")
        .component("sdImageSelector", {
            templateUrl: imageSelectorTemplateUrl,
            controller: ImageSelectorController,
            bindings: {
                authz: "<"
            }
        })
        .component("sdImageEditor", {
            templateUrl: imageEditorTemplateUrl,
            controller: ImageEditorController,
            bindings: {
                authz: "<"
            }
        });

    imageSelectorTemplateUrl.$inject = ["spa.config.APP_CONFIG"];
    function imageSelectorTemplateUrl (APP_CONFIG) {
        return APP_CONFIG.image_selector_html;
    }

    imageEditorTemplateUrl.$inject = ["spa.config.APP_CONFIG"];
    function imageEditorTemplateUrl (APP_CONFIG) {
        return APP_CONFIG.image_editor_html;
    }

    ImageSelectorController.$inject = ["$scope", "spa.subjects.Image", "$stateParams", "spa.authz.Authz"];
    function ImageSelectorController ($scope, Image, $stateParams, Authz) {
        var vm = this;

        vm.$onInit = function () {
            console.log("ImageSelectorController", $scope);

            $scope.$watch(function () { return Authz.getAuthorizedUserId(); }, function () {
                if(!$stateParams.id) {
                    vm.items = Image.query();
                }
            });
        };
    }

    ImageEditorController.$inject = ["$scope", "spa.subjects.Image", "$stateParams", "$state", "spa.subjects.ImageThing", "spa.subjects.ImageLinkableThing", "$q", "spa.authz.Authz"];
    function ImageEditorController ($scope, Image, $stateParams, $state, ImageThing, ImageLinkableThing, $q, Authz) {
        var vm = this;
        vm.create = create;
        vm.update = update;
        vm.clear = clear;
        vm.remove = remove;

        vm.$onInit = function () {
            console.log("ImageEditorController", $scope);
            $scope.$watch(
                function () { return Authz.getAuthorizedUserId(); },
                function() {
                    if($stateParams.id) {
                        reload($stateParams.id);
                    } else {
                        newResource();
                    }
                });
        };

        function newResource () {
            vm.item = new Image();
            return vm.item;
        }

        function reload(imageId) {
            var itemId = imageId ? imageId : vm.item.id;
            vm.item = Image.get({id: itemId});
            vm.things = ImageThing.query({ image_id: itemId });
            vm.linkable_things = ImageLinkableThing.query({ image_id: itemId });
            $q.all([vm.item.$promise, vm.things.$promise]).catch(handleError);
        }


        function update () {
            vm.item.errors = null;

            var update = vm.item.$update();
            linkThings(update);
        }

        function linkThings (parentPromise) {
            var resource;
            var promises = [];

            if (parentPromise) promises.push(parentPromise);

            angular.forEach(vm.selected_linkables, function (linkable) {
                resource = ImageThing.save({ image_id: vm.item.id }, { thing_id: linkable });
                promises.push(resource.$promise);
            });

            vm.selected_linkables = [];
            $q.all(promises).then(function (response){
                $scope.imageform.$setPristine();
                $state.reload();
            }, handleError);
        }

        function remove () {
            vm.item.errors = null;

            vm.item.$delete().then(function () {
                clear();
            }, handleError);
        }

        function clear () {
            newResource();
            $state.go(".", { id: null });
        }

        function create () {
            vm.item.errors = null;

            vm.item.$save().then(function (){
                $state.go(".", { id: vm.item.id });
            }, handleError);
        }

        function handleError (response) {
            if (response.data) {
                vm.item["errors"] = response.data.errors;
            }

            if (!vm.item.errors) {
                vm.item["errors"] = {};
                vm.item["errors"]["full_messages"] = [response];
            }

            $scope.imageform.$setPristine();
        }
    }
})();
