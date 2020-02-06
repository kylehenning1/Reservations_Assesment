<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Home.aspx.cs" Inherits="Reservations.Home" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.4.1/jquery.min.js"></script>
    <link type="text/css" rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/jsgrid/1.5.3/jsgrid.min.css" />
    <link type="text/css" rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/jsgrid/1.5.3/jsgrid-theme.min.css" />
    <script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/jsgrid/1.5.3/jsgrid.min.js"></script>
    <link type="text/css" rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css" />
    <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.7/umd/popper.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/moment.js/2.24.0/moment.min.js"></script>
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/js/bootstrap.min.js"></script>
    <link href="Style/StyleSheet.css" rel="stylesheet" />
    <title>Home</title>
</head>
<body>

<%--    <div class="text-center">
      <div class="spinner-border" role="status">
        <span class="sr-only">Loading...</span>
      </div>
    </div>--%>
    <div class="navbar navbar-dark bg-dark box-shadow">
        <div class="container d-flex justify-content-between">
            <a href="#" class="navbar-brand d-flex align-items-center">
                <img src="https://cdns.iconmonstr.com/wp-content/assets/preview/2012/240/iconmonstr-calendar-3.png" alt="Calendar 3" width="20" height="20" style="margin-right: 10px" />
                <strong>Reservations</strong>
            </a>
        </div>
    </div>
    <div class="container">
        <div class="row">
            <div class="col">
                <p style="right: 13px; top:5px; position: absolute; z-index:10;">
                    <a href="New Reservation.aspx" class="btn btn-success my-2 float-right"><span style="font-weight:bolder">+</span> New Reservation</a>
                </p>
                <br />
                <div id="ExistingReservationsDiv">
                    <h3>Existing Reservations</h3>
                    <div>
                        <div id="jsGrid">
                        </div>
                    </div>
                </div>
                <div id="LecturersAndHallsDiv" style="display:none;" class="row">
                    <div class="col-7">
                        <h3>Lecturers</h3>
                        <div>
                            <div id="jsGridLecturers">
                            </div>
                        </div>
                    </div>
                    <div class="col-5">
                        <h3>Lecture Halls</h3>
                        <div>
                            <div id="jsGridLectureHalls">
                            </div>
                        </div>
                    </div>
                </div>
                <p style="bottom: 0px; position: fixed;">
                    <button id="showExistingReservationsButton" class="btn btn-primary my-2">Show existing reservations</button>
                    <button id="showHallsAndLecturersButton" class="btn btn-secondary my-2">Show lecturers and halls</button>
                </p>
            </div>
        </div>
    </div>
</body>
</html>

<script>

    $("#showExistingReservationsButton").click(function () {
        $("#ExistingReservationsDiv").show();
        $("#LecturersAndHallsDiv").hide();
    });

    $("#showHallsAndLecturersButton").click(function () {
        $("#ExistingReservationsDiv").hide();
        $("#LecturersAndHallsDiv").show();
    });

    var gridDataLecturers = [];
    var gridDataReservations = [];
    var gridDataLectureHalls = [];

    function getReservations() {
        $.getJSON("api/Reservations",
            function (data) {
                gridDataReservations.length = 0;
                // Loop through the list of reservations.  
                $.each(data, function (key, val) {
                    // Add a table row for the student.  
                    var row = {
                        'Id': val.Id, 'From': moment(val.From).format("YYYY/MM/DD HH:mm"), 'To': moment(val.To).format("YYYY/MM/DD HH:mm"), 'Lecture Hall Number': val.LectureHallNumber, 'Lecturer': val.Lecturer, 'Subject': val.Subject
                    };
                    gridDataReservations.push(row);
                });
            });
    }
           
    function getLecturers() {
        $.getJSON("api/Lecturers",
            function (data) {
                gridDataLecturers.length = 0;
                // Loop through the list of lecturers.
                $.each(data, function (key, val) {
                    // Add a table row for the lecturer.
                    var row = {
                        'Id': val.Id, 'Title': val.Title.charAt(0).toUpperCase() + val.Title.slice(1), 'Name': val.Name, 'Surname': val.Surname, 'Subject': val.Subject
                    };
                    gridDataLecturers.push(row);
                });
            });
    }

    function getLectureHalls() {
        $.getJSON("api/LectureHalls",
            function (data) {
                gridDataLectureHalls.length = 0;
                // Loop through the list of lectureHalls.
                $.each(data, function (key, val) {
                    // Add a table row for the lectureHall.
                    var row = {
                        'Number': val.Number, 'Capacity': val.Capacity
                    };
                    gridDataLectureHalls.push(row);
                });
            });
    }
    
    var initializeReservationsGrid = function () {
        setTimeout(
            function () {
                $("#jsGrid").jsGrid({
                    width: "100%",
                    height: "auto",

                    inserting: false,
                    editing: false,
                    sorting: true,
                    paging: true,

                    data: gridDataReservations,

                    fields: [{ name: "Id", type: "number", validate: "required", visible: false },
                    { name: "From", type: "text", width: 80 },
                    { name: "To", type: "text", width: 80 },
                    { name: "Lecture Hall Number", type: "text", width: 80 },
                    { name: "Lecturer", type: "text", width: 110 },
                    { name: "Subject", type: "text", width: 50 },
                    { type: "control" , visible: false}]
                })
            },
            400);
    }

    var initializeLecturersGrid = function () {
        setTimeout(
            function () {
                $("#jsGridLecturers").jsGrid({
                    width: "100%",
                    height: "auto",

                    inserting: false,
                    editing: false,
                    sorting: true,
                    paging: true,

                    data: gridDataLecturers,

                    fields: [{ name: "Id", type: "number", validate: "required", visible: false},
                    { name: "Title", type: "text", width: 10 },
                    { name: "Name", type: "text", width: 50 },
                    { name: "Surname", type: "text", width: 50 },
                    { name: "Subject", type: "text", width: 100 },
                    { type: "control", visible: false }]
                })
            },
            400);
    }

    var initializeLectureHallsGrid = function () {
        setTimeout(
            function () {
                $("#jsGridLectureHalls").jsGrid({
                    width: "100%",
                    height: "auto",

                    inserting: false,
                    editing: false,
                    sorting: true,
                    paging: true,

                    data: gridDataLectureHalls,

                    fields: [{ name: "Number", type: "number", width: 20, validate: "required" },
                    { name: "Capacity", type: "number", width: 50 },
                    { type: "control", visible: false }]
                })
            },
        400);
    }
    
    var setupReservationsGrid = function () {
        getReservations();
        initializeReservationsGrid();
    }

    var setupLecturerGrid = function () {
        getLecturers();
        initializeLecturersGrid();
    }

    var setupLectureHallsGrid = function () {
        getLectureHalls();
        initializeLectureHallsGrid();
    }

    $(document).ready(setupReservationsGrid);
    $(document).ready(setupLecturerGrid);
    $(document).ready(setupLectureHallsGrid);

</script>
