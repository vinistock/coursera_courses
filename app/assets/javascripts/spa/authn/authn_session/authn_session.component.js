(function () {
    "use strict";

    angular.module("spa.authn")
        .component("sdAuthnSession", {
           templateUrl: templateUrl,
            controller: AuthnSessionController
        });

    templateUrl.$inject = ["spa.config.APP_CONFIG"];
    function templateUrl (APP_CONFIG) {
        return APP_CONFIG.authn_session_html;
    }

    AuthnSessionController.$inject = ["$scope"];
    function AuthnSessionController ($scope) {
        var vm = this;

        vm.$onInit = function () {
            console.log("AuthnSessionController", $scope);
        };
    }
})();
