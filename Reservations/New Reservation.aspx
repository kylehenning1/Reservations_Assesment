<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="New Reservation.aspx.cs" Inherits="Reservations.Hello" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.4.1/jquery.min.js"></script>
    <link type="text/css" rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css" />
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/js/bootstrap.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/1.11.1/jquery.min.js"></script>
    <script src="https://code.jquery.com/ui/1.12.0/jquery-ui.min.js"></script>
    <script src="http://ajax.googleapis.com/ajax/libs/jquery/1.10.2/jquery.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery-datetimepicker/2.5.20/jquery.datetimepicker.min.js"></script>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/jquery-datetimepicker/2.5.20/jquery.datetimepicker.min.css" rel="stylesheet" />
    <link href="https://cdnjs.cloudflare.com/ajax/libs/jqueryui/1.12.1/jquery-ui.min.js" rel="stylesheet" />
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery-datetimepicker/2.5.20/jquery.datetimepicker.full.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/moment.js/2.24.0/moment.min.js"></script>
    <title>Home</title>
</head>
<body>
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
                <div>
                    <br />
                    <div id="errorMessageDiv" class="alert alert-danger alert-dismissible fade show" style="display: none;">
                        <strong>Error!</strong> A problem has been occurred while submitting your data.
                        <button type="button" class="close" data-dismiss="alert">&times;</button>
                        <div>
                            <ul id="errorList">
                            </ul>
                        </div>
                    </div>
                    <div id="successMessageDiv" class="alert alert-success" style="display: none;">
                        <strong>Success!</strong> Reservation set.
                        <button type="button" class="close" data-dismiss="alert">&times;</button>
                    </div>
                    <h3>New Reservation</h3>
                    <div class="form-group row">
                        <label for="fromDateTimePicker" class="col-sm-2 col-form-label">From</label>
                        <div class="col-sm-4">
                            <input id="fromDateTimePicker" class="form-control " type="text" />
                        </div>
                    </div>
                    <div class="form-group row">
                        <label for="toDateTimePicker" class="col-sm-2 col-form-label">To</label>
                        <div class="col-sm-4">
                            <input id="toDateTimePicker" class="form-control" type="text" />
                        </div>
                    </div>
                    <div class="form-group row">
                        <label for="lectureHallSelect" class="col-sm-2 col-form-label">Hall</label>
                        <div class="col-sm-4">
                            <select class="form-control" id="lectureHallSelect">
                            </select>
                        </div>
                        <label for="lblCapacity" class="col-sm-6 col-form-label">Capacity: <span id="CapacitySpan"></span></label>
                    </div>
                    <div class="form-group row">
                        <label for="lecturerSelect" class="col-sm-2 col-form-label">Lecturer</label>
                        <div class="col-sm-4">
                            <select class="form-control" id="lecturerSelect">
                            </select>
                        </div>
                        <label for="lblSubject" class="col-sm-6 col-form-label">Subject: <span id="subjectSpan"></span></label>
                    </div>
                    <button id="SaveBtn" type="button" class="btn btn-primary">Save</button>
                    <a type="button" href="Home.aspx" class="btn btn-secondary">Back</a>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
<script type="text/javascript">
    var lectureHalls = [];
    var lecturers = [];

    $("#SaveBtn").click(function () {
        postNewReservation();
    });

    $('#fromDateTimePicker').datetimepicker();
    $('#toDateTimePicker').datetimepicker();
    var errorList = $("#errorList");

    function getLectureHalls() {
        $.getJSON("api/LectureHalls",
            function (data) {
                // Loop through the list of reservations.  
                $.each(data, function (key, val) {
                    // Add a table row for the student.  
                    $("#lectureHallSelect").append("<option data-capacity='" + val.Capacity + "' value='" + val.Number + "'>" + val.Number + "</option>");
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
                    $("#lecturerSelect").append("<option data-subject='" + val.Subject + "' value='" + val.Id + "'>" + val.Title.charAt(0).toUpperCase() + val.Title.slice(1) + " " + val.Name + " " + val.Surname + "</option>");
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
        var fromDateTime = $("#fromDateTimePicker").val();
        var toDateTime = $("#toDateTimePicker").val();

        $.ajax({
            type: "POST",
            url: "api/Reservations",
            data: { From: fromDateTime, To: toDateTime, LectureHallNumber: lectureHallId, LecturerId: lecturerId },
            //data: { From: '5/14/2019 11:00:00 AM', To: '5/14/2019 10:00:00 AM', LectureHallNumber: '3', LecturerId: '4' },
            success: function (data) {

                if ((data & 128) != 0) {
                    $("#errorMessageDiv").hide();
                    $("#successMessageDiv").show();
                    errorList.children.length = 0;
                }
                else 
                    $("#errorMessageDiv").show();
                
                if ((data & 1) != 0) 
                    errorList.append("<li>The from date must be the same as the to date.</li>");
                
                if ((data & 2) != 0) 
                    errorList.append('<li>The to date is set before the from date.</li>');
                
                if ((data & 4) != 0) 
                    errorList.append('<li>A new reservation must be included inside working hours i.e. between 8 And 18.</li>');
                
                if ((data & 8) != 0) 
                    errorList.append('<li>A new reservation may at most be 3 hours in duration.</li>');
                
                if ((data & 16) != 0) 
                    errorList.append('<li>An existing reservation has overlapping hours in the same hall - Please adjust hours or hall.</li>');
                
                if ((data & 32) != 0) 
                    errorList.append('<li>Lecturer does not exist. Stop hacking.</li>');
                
                if ((data & 64) != 0) 
                    errorList.append('<li>Hall does not exist. Stop hacking.</li>');

                console.log(data);
            },
            error: function () {
                alert("error");
            },
            dataType: "json"
        });
    }

    $("#lectureHallSelect").change(function () {
        $("#CapacitySpan").text($(this).find(':selected').data('capacity'));
    });

    $("#lecturerSelect").change(function () {
        $("#subjectSpan").text($(this).find(':selected').data('subject'));
    });

    var intializeSubjectSpan = function () {
        setTimeout(function () {
            $("#subjectSpan").text($("#lecturerSelect").find(':selected').data('subject'));
        }, 400)
    }
    var intializeCapacitySpan = function () {
        setTimeout(function () {
            $("#CapacitySpan").text($("#lectureHallSelect").find(':selected').data('capacity'));
        }, 400)
    }

    var initializeFromDate = function () {
        var currentTime = new Date();
        var convertedTime = moment(currentTime).format("YYYY/MM/DD HH:mm");
        $("#fromDateTimePicker").val(convertedTime);
    };

    var initializeToDate = function () {
        var currentTime = new Date();
        var convertedTime = moment(currentTime).add(1, 'hours').format("YYYY/MM/DD HH:mm");
        $("#toDateTimePicker").val(convertedTime);
    };

    $(document).ready(getLectureHalls);
    $(document).ready(getLecturers);
    $(document).ready(intializeSubjectSpan);
    $(document).ready(intializeCapacitySpan);
    $(document).ready(initializeFromDate);
    $(document).ready(initializeToDate);

</script>
