angular.module "cfxnes"

.directive "videoOutput", ->
    restrict: "A"
    link: (scope, element, attrs) ->
        emulator = scope.$eval attrs["videoOutput"]
        emulator.setVideoOutput element[0]
