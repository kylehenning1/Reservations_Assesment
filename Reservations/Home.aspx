<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Home.aspx.cs" Inherits="Reservations.Home" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
    <head runat="server">
        <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.4.1/jquery.min.js"></script>
        <link type="text/css" rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/jsgrid/1.5.3/jsgrid.min.css" />
        <link type="text/css" rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/jsgrid/1.5.3/jsgrid-theme.min.css" />
        <script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/jsgrid/1.5.3/jsgrid.min.js"></script>
        <link type="text/css" rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css"/>
        <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.7/umd/popper.min.js"></script>
        <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/js/bootstrap.min.js"></script>
        <link href="Style/StyleSheet.css" rel="stylesheet" />
        <title>Home</title>
    </head>
    <body>
        <div class="navbar navbar-dark bg-dark box-shadow">
        <div class="container d-flex justify-content-between">
          <a href="#" class="navbar-brand d-flex align-items-center">
            <%--<svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="mr-2"><path d="M23 19a2 2 0 0 1-2 2H3a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h4l2-3h6l2 3h4a2 2 0 0 1 2 2z"></path><circle cx="12" cy="13" r="4"></circle></svg>--%>
            <img src="https://cdns.iconmonstr.com/wp-content/assets/preview/2012/240/iconmonstr-calendar-3.png" alt="Calendar 3" width="20" height="20" style="margin-right:10px"/>
              <strong>Reservations</strong>
          </a>
        </div>
      </div>
    <section class="jumbotron text-center">
        <h1>Reservations</h1>
        <p class="lead text-muted"><span class="font-italic">(.n)</span> The art of planning.</p>
        <p>
            <a href="Home.aspx" id="showBtn" class="btn btn-primary my-2">Show grid</a>
            <a href="New Reservation.aspx" class="btn btn-secondary my-2">New Reservation</a>
        </p>
    </section>
        <div class="container">
            <div class="col">
            <form id="form1" runat="server">
                <div>
                    <div id="jsGrid">

                    </div>                    
	            </div>
            </form>
            </div>
        </div>
    </body>
</html>

<script>
    
    $("#hideBtn").click(function () {
        $("#jsGrid").hide();
    });

    $("#showBtn").click(function () {
        $("#jsGrid").show();
    });

    var clients = [];
    function getReservations() {
        $.getJSON("api/Reservations",
            function (data) {
                // Loop through the list of reservations.  
                $.each(data, function (key, val) {
                    // Add a table row for the student.  
                    var row = {
                        'Id': val.Id, 'From': val.From, 'To': val.To, 'Lecture Hall Number': val.LectureHallNumber, 'Lecturer': val.Lecturer, 'Subject': val.Subject
                    };
                    clients.push(row);
                });
            });
    setTimeout(
        function () {
            $("#jsGrid").jsGrid({
                width: "100%",
                height: "400px",

                inserting: true,
                editing: false,
                sorting: true,
                paging: true,

                data: clients,

                fields: [
                    { name: "Id", type: "number", width: 20, validate: "required" },
                    { name: "From", type: "text", width: 50 },
                    { name: "To", type: "text", width: 50 },
                    { name: "Lecture Hall Number", type: "text", width: 100 },
                    { name: "Lecturer", type: "text", width: 150 },
                    { name: "Subject", type: "text", width: 50 },
                    { type: "control" }
                ]
            })
        },
    400);
    }
    $(document).ready(getReservations);
</script>