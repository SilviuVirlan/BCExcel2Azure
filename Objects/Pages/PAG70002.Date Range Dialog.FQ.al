page 70002 "Date-Range Dialog.FQ"
{
    PageType = StandardDialog;
    ContextSensitiveHelpPage = 'ui-enter-date-ranges';

    layout
    {
        area(content)
        {
            field(StartDate; StartDateValue) { ApplicationArea = All; Caption = 'Start Date'; ToolTip = 'Specifies Start Date.'; }
            field(EndDate; EndDateValue) { ApplicationArea = All; Caption = 'End Date'; ToolTip = 'Specifies End Date.'; }
        }
    }

    procedure SetDates(_start: Date; _end: Date)
    begin
        StartDateValue := _start;
        EndDateValue := _end;
    end;

    procedure GetDates(var _start: Date; var _end: Date)
    begin
        _start := StartDateValue;
        _end := EndDateValue;
    end;

    var
        StartDateValue: Date;
        EndDateValue: Date;
}