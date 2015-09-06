export chart_epm_js_tpl = [[
    var ctx = document.getElementById("chart_epm").getContext("2d");
    var data = {
        labels: [%s],
        datasets: [{data: [%s]}]
    };
    var options = {};
    var myBarChart = new Chart(ctx).Bar(data, options);
]]

class About extends require "views.base"
  content: =>

    h2 class: "list-header", "About Lua Toolbox"
    div class: "cell", ->
        p ->
            text "Lua Toolbox is an "
            a href: "https://github.com/catwell/lua-toolbox/", "Open Source"
            text " website aiming at helping with the discovery and selection"
            text " of Lua modules."
        p ->
            text "For that purpose, it lets its users endorse modules and"
            text " ranks them by number of endorsements. It also has a labels"
            text " system to classify modules by intended use."
        p ->
            text "To help with the project or report bugs, use GitHub issues."
            text " To report security issues that should be fixed before they"
            text " are disclosed, please get in touch with "
            a href:  "http://catwell.info", "Pierre Chapuis"
            text "."

    h2 class: "list-header", "Metrics"

    div class: "cell", ->
        h3 "Endorsements per module"
        canvas id: "chart_epm", class: "about_chart"
        script src: "/static/js/Chart.min.js"
        script ->
            raw string.format chart_epm_js_tpl,
                "#{table.concat(@endorsement_data.labels, ",")}", 
                "#{table.concat(@endorsement_data.values, ",")}"
