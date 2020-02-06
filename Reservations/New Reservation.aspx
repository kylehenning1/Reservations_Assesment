<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="New Reservation.aspx.cs" Inherits="Reservations.Hello" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
    <head runat="server">
        <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.4.1/jquery.min.js"></script>
        <link type="text/css" rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css"/>
        <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/js/bootstrap.min.js"></script>


        <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/1.11.1/jquery.min.js"></script>
        <script src="https://code.jquery.com/ui/1.12.0/jquery-ui.min.js"></script>
        <script src="http://ajax.googleapis.com/ajax/libs/jquery/1.10.2/jquery.min.js"></script>
        <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery-datetimepicker/2.5.20/jquery.datetimepicker.min.js"></script>
        <link href="https://cdnjs.cloudflare.com/ajax/libs/jquery-datetimepicker/2.5.20/jquery.datetimepicker.min.css" rel="stylesheet" />
        <link href="https://cdnjs.cloudflare.com/ajax/libs/jqueryui/1.12.1/jquery-ui.min.js" rel="stylesheet" />
        <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery-datetimepicker/2.5.20/jquery.datetimepicker.full.min.js"></script>

        <title>Home</title>
    </head>
    <body>
        <div class="navbar navbar-dark bg-dark box-shadow">
        <div class="container d-flex justify-content-between">
          <a href="#" class="navbar-brand d-flex align-items-center">
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
            <a href="New Reservation.aspx" id="hideBtn" class="btn btn-secondary my-2">New Reservation</a>
        </p>
    </section>
        <div class="container">
            <div class="col">
            <form id="form1" runat="server">
                <div>
                    <div class="form-group row">
                        <label for="datetimepicker1" class="col-sm-2 col-form-label">From</label>
                        <div class="col-sm-10">
                            <input id="datetimepicker1"  class="form-control " type="text" />
                        </div>
                        <div class="invalid-feedback" id="invalidFeedbackDTP1">
                          To before somehting something.
                        </div>
                    </div>
                    <div class="form-group row">
                        <label for="datetimepicker2" class="col-sm-2 col-form-label">To</label>
                        <div class="col-sm-10">
                            <input id="datetimepicker2" class="form-control" type="text" />
                        </div>
                        <div class="invalid-feedback" id="invalidFeedbackDTP2">
                          To before somehting something.
                        </div>
                    </div>
                    <div class="form-group row">
                        <label for="lectureHallSelect" class="col-sm-2 col-form-label">Hall</label>
                        <div class="col-sm-4">
                            <select class="form-control" id="lectureHallSelect">
                            </select>
                        </div>
                        <div class="invalid-feedback" id="invalidFeedbackHallSelect">
                          Hall does not exist.
                        </div>
                        <label for="lblCapacity" class="col-sm-6 col-form-label">Capacity: 10</label>
<%--                        <div class="col-sm-4">
                            <span id="lblCapacity" class="label label-default"></span>
                        </div>--%>
                    </div>
                    <div class="form-group row">

                    </div>
                    <div class="form-group row">
                        <label for="lecturerSelect" class="col-sm-2 col-form-label">Lecturer</label>
                        <div class="col-sm-4">
                            <select class="form-control" id="lecturerSelect">
                            </select>
                        </div>
                        <div class="invalid-feedback" id="invalidFeedbackLecturerSelect">
                          Lecturer does not exist.
                        </div>
                        <label for="lblSubject" class="col-sm-6 col-form-label">Subject: Technology</label>
<%--                        <div class="col-sm-4">
                            <span id="lblSubject" class="label label-default">10</span>
                        </div>--%>
                    </div>
                    <button id="SaveBtn" type="button" class="btn btn-primary">Save</button>                          
                    <button type="button" class="btn btn-light">Clear</button>
	            </div>
            </form>
            </div>
        </div>
    </body>
</html>
<script type="text/javascript">
    var lectureHalls = [];
    var lecturers = [];

    function getLectureHalls() {
        $.getJSON("api/LectureHalls",
            function (data) {
                // Loop through the list of reservations.  
                $.each(data, function (key, val) {
                    // Add a table row for the student.  
                    $("#lectureHallSelect").append("<option value='" + val.Number + "'>" + val.Number + "</option>");
                    var row = {
                        'Number': val.Number, 'Capacity': val.Capacity
                    };
                    lectureHalls.push(row);
                });
            });
    }

    function getLecturers() {
        $.getJSON("api/Lecturers",
            function (data) {
                // Loop through the list of reservations.  
                $.each(data, function (key, val) {
                    // Add a table row for the student.  
                    $("#lecturerSelect").append("<option value='" + val.Id + "'>" + val.Title + " " + val.Name + " " + val.Surname + "</option>");
                });
            });
    }

    //Validation Enums
    //Default = 0,
    //MoreThanOneDay = 1,
    //ToBeforeFrom = 2,
    //OutsideWorkingHours = 4,
    //TooLong = 8,
    //Conflicting = 16,
    //LecturerDoesNotExist = 32,
    //HallDoesNotExist = 64,
    //Ok = 128

    function postNewReservation() {
        var lectureHallId = $("#lectureHallSelect").val();
        var lecturerId = $("#lecturerSelect").val();
        var fromDateTime = $("#datetimepicker1").val();
        var toDateTime = $("#datetimepicker2").val();

        $.ajax({
            type: "POST",
            url: "api/Reservations",
            data: { From: fromDateTime, To: toDateTime, LectureHallNumber: lectureHallId, LecturerId: lecturerId },
            //data: { From: '5/14/2019 11:00:00 AM', To: '5/14/2019 10:00:00 AM', LectureHallNumber: '3', LecturerId: '4' },
            success: function (data) {

                if ((data & 1) != 0) {
                    alert("The from date must be the same as the to date.");
                }
                if ((data & 2) != 0) {
                    alert("The to date is set before the from date.");
                }
                if ((data & 4) != 0) {
                    alert("A new reservation must be included inside working hours i.e. between 8 And 18.");
                }
                if ((data & 8) != 0) {
                    alert("A new reservation may at most be 3 hours in duration.");
                }
                if ((data & 16) != 0) {
                    alert("An existing reservation has overlapping hours in the same hall - Please adjust hours or hall.");
                }
                if ((data & 32) != 0) {
                    $("#lecturerSelect").addClass("is-invalid");
                }
                if ((data & 64) != 0) {
                    $("#lectureHallSelect").addClass("is-invalid");
                }
                console.log(data);                  
            },
            error: function () {
                alert("error");
            },
            dataType: "json"
        });
    }
    
    $("#SaveBtn").click(function () {
        postNewReservation();
    });

    $('#datetimepicker1').datetimepicker();
    $('#datetimepicker2').datetimepicker();

    $(document).ready(getLectureHalls);
    $(document).ready(getLecturers);

</script>