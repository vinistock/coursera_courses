(function () {
    "use strict";

    angular.module("spa.subjects")
        .component("sdImageSelector", {
            templateUrl: imageSelectorTemplateUrl,
            controller: ImageSelectorController
        })
        .component("sdImageEditor", {
            templateUrl: imageEditorTemplateUrl,
            controller: ImageEditorController
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

    ImageEditorController.$inject = ["$scope", "spa.subjects.Image", "$stateParams"];
    function ImageEditorController ($scope, Image, $stateParams) {
        var vm = this;

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
    }
})();
