namespace Reservations.Services
{
    using System;
    using System.Collections.Generic;
    using System.Linq;

    using AutoMapper;
    using Db;
    using Models;

    /// <summary>
    /// Implementation of business logic methods concerning reservations
    /// </summary>
    public class ReservationsService : IReservationsService
    {
        private readonly GetAllReservationsQuery _queryAll;
        private readonly GetReservationByIdQuery _queryById;
        private readonly AddReservationQuery _queryAdd;
        private readonly DeleteReservationQuery _queryDelete;

        private readonly GetAllLecturersQuery _queryAllLecturers;
        private readonly GetAllLectureHallsQuery _queryAllLectureHalls;

        public ReservationsService(GetAllReservationsQuery queryAll, GetReservationByIdQuery queryById, AddReservationQuery queryAdd, DeleteReservationQuery queryDelete, GetAllLecturersQuery queryAllLecturers, GetAllLectureHallsQuery queryAllLectureHalls)
        {
            _queryAll = queryAll;
            _queryById = queryById;
            _queryAdd = queryAdd;
            _queryDelete = queryDelete;
            _queryAllLecturers = queryAllLecturers;
            _queryAllLectureHalls = queryAllLectureHalls;
        }

        /// <summary>
        /// Lists all reservations that exist in db
        /// </summary>
        public IEnumerable<ReservationItem> All()
        {
            return Mapper.Map<IEnumerable<ReservationItem>>(_queryAll.Execute().ToList());
        }

        /// <summary>
        /// Gets single reservation by its id
        /// </summary>
        public ReservationItem GetById(int id)
        {
            return Mapper.Map<ReservationItem>(_queryById.Execute(id));
        }

        /// <summary>
        /// Checks whether given reservation can be added.
        /// Performs logical and business validation.
        /// </summary>
        public ValidationResult ValidateNewReservation(NewReservationItem newReservation)
        {
            if (newReservation == null)
            {
                throw new ArgumentNullException("newReservation");
            }

            var result = ValidationResult.Default;

            if (newReservation.From.DayOfWeek != newReservation.To.DayOfWeek)
                result |= ValidationResult.MoreThanOneDay;

            if (newReservation.From > newReservation.To)
                result |= ValidationResult.ToBeforeFrom;

            if ((newReservation.From.Hour < 8) || (newReservation.From.Hour > 18) || (newReservation.From.Hour == 18 && newReservation.From.Minute != 0) ||
                (newReservation.To.Hour < 8) || (newReservation.To.Hour > 18) || (newReservation.To.Hour == 18 && newReservation.To.Minute != 0))
                result |= ValidationResult.OutsideWorkingHours;
            
            var secondsBetweenToAndFrom = (newReservation.To - newReservation.From).TotalSeconds;

            if (secondsBetweenToAndFrom > 10800) //10800 is 3 hours in seconds
                result |= ValidationResult.TooLong;

            var existingReservations = _queryAll.Execute();
            var listOfPossibleOverlappingReservations = existingReservations.Select(x => x).Where(x => x.Hall.Number == newReservation.LectureHallNumber);

            foreach(Reservation res in listOfPossibleOverlappingReservations.ToList())
            {
                if (res.From > newReservation.From && res.To <= newReservation.To)
                { 
                    result |= ValidationResult.Conflicting;
                    break;
                }
                if (res.From < newReservation.From && res.To >= newReservation.To)
                { 
                    result |= ValidationResult.Conflicting;
                    break;
                }
                if (res.From == newReservation.From && res.To == newReservation.To)
                { 
                    result |= ValidationResult.Conflicting;
                    break;
                }
                if (res.From >= newReservation.From && res.To < newReservation.To)
                {
                    result |= ValidationResult.Conflicting;
                    break;
                }
                if (res.From <= newReservation.From && res.To > newReservation.To)
                {
                    result |= ValidationResult.Conflicting;
                    break;
                }
            }

            var lectureHalls = _queryAllLectureHalls.Execute();

            if (!lectureHalls.Any(x => x.Number == newReservation.LectureHallNumber))
                result |= ValidationResult.HallDoesNotExist;

            var lecturers = _queryAllLecturers.Execute();

            if (!lecturers.Any(x => x.Id == newReservation.LecturerId))
                result |= ValidationResult.LecturerDoesNotExist;

            // TODO
            // Note that for reservation dates, we take into account only date and an hour, minutes and seconds don't matter.

            return result;
        }

        /// <summary>
        /// Tries to add given reservation to db, after validating it
        /// </summary>
        public ValidationResult Add(NewReservationItem newReservation)
        {
            if (newReservation == null)
            {
                throw new ArgumentNullException("newReservation");
            }

            var result = ValidateNewReservation(newReservation);
            if ((result & ValidationResult.Ok) == ValidationResult.Ok)
            {
                var reservation = new Reservation
                {
                    From = newReservation.From,
                    To = newReservation.To,
                    Lecturer = _queryAllLecturers.Execute().Single(p => p.Id == newReservation.LecturerId),
                    Hall = _queryAllLectureHalls.Execute().Single(p => p.Number == newReservation.LectureHallNumber),
                };

                _queryAdd.Execute(reservation);
            }

            return result;
        }

        /// <summary>
        /// Deletes (if exists) reservation from db (by its id)
        /// </summary>
        public void Delete(int id)
        {
            _queryDelete.Execute(id);
        }

        /// <summary>
        /// Returns all reservations (listed chronologically) on a given day concerning given hall. 
        /// If a given lecture hall does not exist, throws exception
        /// </summary>
        public IEnumerable<ReservationItem> GetByDay(DateTime day, int hallNumber)
        {
            if (!_queryAllLectureHalls.Execute().Any(p => p.Number == hallNumber))
            {
                throw new ArgumentException("Given hall does not exist");
            }

            var reservations =
                _queryAll.Execute().Where(p => p.Hall.Number == hallNumber).Where(p => p.From.Date == day.Date).OrderBy(p => p.From.Hour);

            return Mapper.Map<IEnumerable<ReservationItem>>(reservations.ToList());
        }

        /// <summary>
        /// Returns statistics (list of pairs [HallNumber, NumberOfFreeHours]) on a given day.
        /// Maximum number of free hours is 10 (working hours are 8-18), minimum 0 of course.
        /// Given day must be from the future (not in the past or today).
        /// </summary>
        public IEnumerable<HallFreeHoursStatisticsItem> GetHallsFreeHoursByDay(DateTime day)
        {
            if (day.Date <= DateTime.Today.Date)
            {
                throw new ArgumentException("Input argument must be a future day");
            }

            var result = new List<HallFreeHoursStatisticsItem>();

            var occupiedHallsStatistics =
                _queryAll.Execute().Where(p => p.From.Date == day.Date).GroupBy(p => p.Hall.Number).Select(p => new HallFreeHoursStatisticsItem
                {
                    HallNumber = p.Key,
                    FreeHoursNumber = p.Sum(r => r.To.Hour - r.From.Hour)
                });

            result.AddRange(_queryAllLectureHalls.Execute().Select(p => new HallFreeHoursStatisticsItem
            {
                HallNumber = p.Number,
                FreeHoursNumber = 10 - (occupiedHallsStatistics.Any(r => r.HallNumber == p.Number) ? occupiedHallsStatistics.Single(r => r.HallNumber == p.Number).FreeHoursNumber : 0)
            }));

            return result;
        }
    }
}