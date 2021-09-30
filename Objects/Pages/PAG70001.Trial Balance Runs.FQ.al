page 70001 "Trial Balance Runs.FQ"
{

    ApplicationArea = All;
    Caption = 'Trial Balance Runs';
    PageType = List;
    SourceTable = "Trial Balance Run.FQ";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Entry No."; Rec."Entry No..FQ")
                {
                    ToolTip = 'Specifies the value of the Entry No. field';
                    ApplicationArea = All;
                }
                field("Start Date"; Rec."Start Date.FQ")
                {
                    ToolTip = 'Specifies the value of the Start Date field';
                    ApplicationArea = All;
                }
                field("End Date"; Rec."End Date.FQ")
                {
                    ToolTip = 'Specifies the value of the End Date field';
                    ApplicationArea = All;
                }
                field("File Created"; Rec."File Created.FQ")
                {
                    ToolTip = 'Specifies the value of the File Created field';
                    ApplicationArea = All;
                }
                field("File Name"; Rec."File Name.FQ")
                {
                    ToolTip = 'Specifies the value of the File Name field';
                    ApplicationArea = All;
                }
                field(URL; Rec."URL.FQ")
                {
                    ToolTip = 'Specifies the value of the URL field';
                    ApplicationArea = All;
                }
                field("File Uploaded"; Rec."File Uploaded.FQ")
                {
                    ToolTip = 'Specifies the value of the File Uploaded field';
                    ApplicationArea = All;
                }
                field(Status; Rec."Status.FQ")
                {
                    ToolTip = 'Specifies the value of the Status field';
                    ApplicationArea = All;
                }
                field(Error; Rec."Error.FQ")
                {
                    ToolTip = 'Specifies the value of the Error field';
                    ApplicationArea = All;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(SetupAzure)
            {
                ApplicationArea = All;
                Caption = 'Azure Connection Setup';
                ToolTip = 'Azure Connection Setup';
                Image = Create;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                RunObject = page "Custom Setup.FQ";
            }
            action(RunManuallyTB)
            {
                ApplicationArea = All;
                Caption = 'Manual Trial Balance';
                ToolTip = 'Run manually trial balance report';
                Image = Create;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                trigger OnAction()
                var
                    _tbWrapper: Codeunit "Trial Balance Wrapper.FQ";
                begin
                    if Rec."Start Date.FQ" <> 0D then
                        _tbWrapper.SetDates(Rec."Start Date.FQ", Rec."End Date.FQ") // rerun
                    else
                        _tbWrapper.SetDates();
                    _tbWrapper.SetOverWrite(true);
                    _tbWrapper.SetRec(Rec);
                    _tbWrapper.Run();
                end;
            }

            action(RunCustomRangeTB)
            {
                ApplicationArea = All;
                Caption = 'Custom Range Trial Balance';
                ToolTip = 'Run manually custom range trial balance extract';
                Image = Create;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                trigger OnAction()
                var
                    _tbWrapper: Codeunit "Trial Balance Wrapper.FQ";
                    _pageDateRange: Page "Date-Range Dialog.FQ";
                    _start, _end : Date;
                begin
                    _tbWrapper.SetDates();
                    _tbWrapper.GetDates(_start, _end);
                    _pageDateRange.SetDates(_start, _end);
                    if _pageDateRange.RunModal() = Action::OK then begin
                        _pageDateRange.GetDates(_start, _end);
                    end else
                        exit;
                    _tbWrapper.SetDates(_start, _end);
                    _tbWrapper.SetOverWrite(false);
                    _tbWrapper.Run();
                end;
            }
        }
    }
}
