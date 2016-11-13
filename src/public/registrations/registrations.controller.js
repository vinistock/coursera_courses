(function () {
    angular.module("public").controller("RegistrationsController", RegistrationsController);

    RegistrationsController.$inject = ["MenuService", "RegistrationsService"];
    function RegistrationsController (MenuService, RegistrationsService) {
        var reg = this;
        reg.completed = false;
        reg.registration = RegistrationsService.getRegistration();

        if (reg.registration) {
            MenuService.getMenuItem(reg.registration.short_name.toUpperCase()).then(function (response) {
                reg.menu_item = response;
            });
        }

        reg.submit = function () {
            MenuService.getMenuItem(reg.short_name.toUpperCase()).then(function (response) {
                reg.invalid = false;

                RegistrationsService.saveRegistration({
                    first_name: reg.first_name,
                    last_name: reg.last_name,
                    email: reg.email,
                    phone_number: reg.phone_number,
                    short_name: reg.short_name
                });

                reg.completed = true;
            }).catch(function (response) {
                reg.invalid = true;
                reg.completed = false;
            });
        };
    }
})();
