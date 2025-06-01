// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Counters} from "@openzeppelin/contracts/utils/Counters.sol";

contract Ticketing {
    using Counters for Counters.Counter;

    struct Event {
        uint256 id;
        address payable organizer;
        string name;
        string description;
        uint256 dateTime;
        uint256 price;
        uint256 maxTickets;
        uint256 ticketsSold;
        bool isActive;
    }

    struct Ticket {
        uint256 id;
        address buyer;
        uint256 eventId;
        string notes;
    }

    Counters.Counter private _eventIdCounter;
    Counters.Counter private _ticketIdCounter;

    mapping(uint256 => Event) public events;
    mapping(address => uint256[]) public eventsOrganizers;
    mapping(uint256 => uint256) public ticketToEvent;
    mapping(address => uint256[]) public ticketsOwner;
    mapping(uint256 => Ticket) public ticketsDetails;

    // ====== Create Event ======
    function createEvent(
        string memory _name,
        string memory _description,
        uint256 _dateTime,
        uint256 _price,
        uint256 _maxTickets
    ) public returns (uint256) {
        uint256 eventId = _eventIdCounter.current();
        _eventIdCounter.increment();

        Event storage ev = events[eventId];
        ev.id = eventId;
        ev.organizer = payable(msg.sender);
        ev.name = _name;
        ev.description = _description;
        ev.dateTime = _dateTime;
        ev.price = _price;
        ev.maxTickets = _maxTickets;
        ev.ticketsSold = 0;
        ev.isActive = true;

        events[eventId] = ev;
        eventsOrganizers[msg.sender].push(eventId);

        return eventId;
    }

    function mintTicket(
        uint256 eventId,
        string memory notes
    ) public payable returns (uint256) {
        Event storage ev = events[eventId];

        require(
            ev.organizer != msg.sender,
            "Cannot buy your own event's tickets"
        );
        require(ev.isActive, "Event not active");
        require(ev.ticketsSold < ev.maxTickets, "Sold out");
        require(msg.value >= ev.price, "Insufficient payment");

        (bool sent, ) = ev.organizer.call{value: msg.value}("");
        require(sent, "Payment failed");

        uint256 ticketId = _ticketIdCounter.current();
        _ticketIdCounter.increment();

        ticketToEvent[ticketId] = eventId;
        ev.ticketsSold++;
        ticketsOwner[msg.sender].push(ticketId);
        ticketsDetails[ticketId] = Ticket(ticketId, msg.sender, eventId, notes);

        if (ev.ticketsSold == ev.maxTickets) {
            ev.isActive = false;
        }

        return ticketId;
    }

    function getEventIdsByOrganizer(
        address organizer
    ) public view returns (uint256[] memory) {
        return eventsOrganizers[organizer];
    }

    function getBoughtTickets(
        address buyer
    ) public view returns (uint256[] memory) {
        return ticketsOwner[buyer];
    }

    function getTicket(
        uint256 ticketId
    ) public view returns (uint256, address, uint256, string memory) {
        Ticket memory ticket = ticketsDetails[ticketId];
        return (ticket.id, ticket.buyer, ticket.eventId, ticket.notes);
    }

    function getEvent(
        uint256 id
    )
        public
        view
        returns (
            uint256,
            address,
            string memory,
            string memory,
            uint256,
            uint256,
            uint256,
            uint256,
            bool
        )
    {
        Event memory ev = events[id];
        return (
            ev.id,
            ev.organizer,
            ev.name,
            ev.description,
            ev.dateTime,
            ev.price,
            ev.maxTickets,
            ev.ticketsSold,
            ev.isActive
        );
    }
}
