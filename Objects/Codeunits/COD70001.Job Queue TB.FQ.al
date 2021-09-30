codeunit 70001 "Job Queue TB.FQ"
{
    trigger OnRun()
    var
        _TBWrapper: Codeunit "Trial Balance Wrapper.FQ";
    begin
        _TBWrapper.SetDates();
        _TBWrapper.SetOverWrite(false);
        _TBWrapper.Run();
    end;
}