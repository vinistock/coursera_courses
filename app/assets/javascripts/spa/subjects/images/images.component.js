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

    ImageSelectorController.$inject = ["$scope", "spa.subjects.Image", "$stateParams"];
    function ImageSelectorController ($scope, Image, $stateParams) {
        var vm = this;

        vm.$onInit = function () {
            console.log("ImageSelectorController", $scope);

            if(!$stateParams.id) {
                vm.items = Image.query();
            }
        };
    }

    ImageEditorController.$inject = ["$scope", "spa.subjects.Image", "$stateParams", "$state"];
    function ImageEditorController ($scope, Image, $stateParams, $state) {
        var vm = this;
        vm.create = create;
        vm.update = update;
        vm.clear = clear;
        vm.remove = remove;

        vm.$onInit = function () {
            console.log("ImageEditorController", $scope);

            if($stateParams.id) {
                vm.item = Image.get({id: $stateParams.id});
            } else {
                newResource();
            }
        };

        function newResource () {
            vm.item = new Image();
            return vm.item;
        }

        function update () {
            $scope.imageform.$setPristine();
            vm.item.errors = null;

            vm.item.$update().then(function () {
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
            $scope.imageform.$setPristine();
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
        }
    }
})();
