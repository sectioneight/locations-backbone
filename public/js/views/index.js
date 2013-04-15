define('LocationListView', [
  'backbone',
  'jquery',
  'underscore',
  'FavoriteLocation',
  'LocationCollection',
  'LocationView',
  'text!templates/locationList.html'
], function(Backbone, $, _, FavoriteLocation, LocationCollection,
            LocationView, template) {
  var LocationListView = Backbone.View.extend({
    el: '#location-list',

    events: {
      'click .add-location': 'addLocation'
    },

    initialize: function() {
      this.template  = _.template(template);
      this.locations = new LocationCollection();

      this.listenTo(this.locations, 'add', this.addOne);
      this.listenTo(this.locations, 'reset', this.render);
    },

    fetchData: function() {
      this.locations.fetch();
    },

    addLocation: function() {
      this.locations.add(new FavoriteLocation());
    },

    addOne: function(location) {
      this.setup();

      var locationView = new LocationView({ model: location }),
          $newEntry = locationView.render().$el.hide();

      this.$el.prepend($newEntry);
      $newEntry.slideDown();
    },

    setup: function() {
      if (this._setup) {
        return;
      }

      this.$el.html(this.template({
        locations: this.locations
      }));

      this._setup = true;
    },

    render: function() {
      var that = this;

      this.locations.each(function(location) {
        that.addOne(location);
      });

      return this;
    }
  });

  return LocationListView;
});
