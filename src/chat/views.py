# from django.shortcuts import render
from django.http import HttpResponse


TEMPLATE = r"""
    <html lang="en">
    <head>
        <meta charset="utf-8"/>
        <meta http-equiv="Cache-control" content="no-cache">
        <script src="http://code.jquery.com/jquery-latest.js"></script>
        <script>
            function update() {
                var response = "";
                var yous = document.getElementsByClassName("you");
                you = yous[yous.length - 1];
                $.ajax({ type: "GET", url: "http://understander.totalgood.org?q=" + you.innerHTML,
                         async: false,
                         success : function(text) { response = text; } });
                var bot = document.createElement("DIV");
                bot.class = "bot";
                bot.innerHTML = response;
                you.parentNode.insertAfter(you, bot);
            }
        </script>
    </head>
    <body>
        <div id="dialog">
            <div class="you"><strong>you: </strong></div>
            <div class="bot"><strong>bot: </strong></div>
        </div>
        <script>
            setInterval(update, 3000);
        </script>
    </body>
    </html>
"""


def index(request):
    return HttpResponse(TEMPLATE)
