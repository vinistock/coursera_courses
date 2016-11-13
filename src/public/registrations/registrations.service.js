(function () {
    "use strict";
    angular.module("common").service("RegistrationsService", RegistrationsService);

    RegistrationsService.$inject = ["$q"];
    function RegistrationsService ($q) {
        var registration;
        var service = this;

        service.saveRegistration = function (data) {
            registration = data;
        };

        service.getRegistration = function () {
            return registration;
        };
    }
})();
