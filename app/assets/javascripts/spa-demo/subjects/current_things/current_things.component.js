(function() {
  "use strict";

  angular
    .module("spa-demo.subjects")
    .component("sdCurrentThings", {
      templateUrl: thingsTemplateUrl,
      controller: CurrentThingsController
    })
    .component("sdCurrentThingInfo", {
      templateUrl: thingInfoTemplateUrl,
      controller: CurrentThingInfoController
    })
      .component("sdCurrentTypes", {
          templateUrl: typesTemplateUrl,
          controller: CurrentTypesController
      })
    ;

    typesTemplateUrl.$inject = ["spa-demo.config.APP_CONFIG"];
  function typesTemplateUrl (APP_CONFIG) {
      return APP_CONFIG.current_types_html;
  }

  thingsTemplateUrl.$inject = ["spa-demo.config.APP_CONFIG"];
  function thingsTemplateUrl(APP_CONFIG) {
    return APP_CONFIG.current_things_html;
  }    
  thingInfoTemplateUrl.$inject = ["spa-demo.config.APP_CONFIG"];
  function thingInfoTemplateUrl(APP_CONFIG) {
    return APP_CONFIG.current_thing_info_html;
  }

    CurrentTypesController.$inject = ["$scope", "spa-demo.subjects.currentSubjects"];
    function CurrentTypesController ($scope, currentSubjects) {
        var vm = this;
        vm.currentType = '';
        vm.onChange = onChange;

        currentSubjects.getThingTypes().$promise.then(function (response) {
            vm.thingTypes = response.types;
        });

        function onChange () {
            $scope.currentType = vm.currentType;
        }
    }

  CurrentThingsController.$inject = ["$scope",
                                     "spa-demo.subjects.currentSubjects"];
  function CurrentThingsController($scope,currentSubjects) {
    var vm=this;
    vm.thingClicked = thingClicked;
    vm.isCurrentThing = currentSubjects.isCurrentThingIndex;

    vm.$onInit = function() {
      console.log("CurrentThingsController",$scope);
    }
    vm.$postLink = function() {
      $scope.$watch(
        function() { return currentSubjects.getThings(); }, 
        function(things) { vm.things = things; }
      );

      $scope.$watch(
        function () { return $("#type-select").val(); },
        function (type) {
          if (type !== '? string: ?') currentSubjects.refresh(type);
        }
      );
    }    
    return;
    //////////////
    function thingClicked(index) {
      currentSubjects.setCurrentThing(index);
    }    
  }

  CurrentThingInfoController.$inject = ["$scope",
                                        "spa-demo.subjects.currentSubjects",
                                        "spa-demo.subjects.Thing",
                                        "spa-demo.authz.Authz"];
  function CurrentThingInfoController($scope,currentSubjects, Thing, Authz) {
    var vm=this;
    vm.nextThing = currentSubjects.nextThing;
    vm.previousThing = currentSubjects.previousThing;

    vm.$onInit = function() {
      console.log("CurrentThingInfoController",$scope);
    }
    vm.$postLink = function() {
      $scope.$watch(
        function() { return currentSubjects.getCurrentThing(); }, 
        newThing 
      );
      $scope.$watch(
        function() { return Authz.getAuthorizedUserId(); },
        function() { newThing(currentSubjects.getCurrentThing()); }
      );        
    }    
    return;
    //////////////
    function newThing(link) {
      vm.link = link; 
      vm.thing = null;
      if (link && link.thing_id) {
        vm.thing=Thing.get({id:link.thing_id});
      }
    }







  }
})();
