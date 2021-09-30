table 70001 "Trial Balance Run.FQ"
{
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "Entry No..FQ"; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Entry No.';
        }
        field(5; "Start Date.FQ"; Date)
        {
            DataClassification = SystemMetadata;
            Caption = 'Start Date';
        }
        field(6; "End Date.FQ"; Date)
        {
            DataClassification = SystemMetadata;
            Caption = 'End Date';
        }
        field(10; "File Name.FQ"; Text[250])
        {
            DataClassification = SystemMetadata;
            Caption = 'File Name';
        }
        field(11; "File Created.FQ"; DateTime)
        {
            DataClassification = ToBeClassified;
            Caption = 'File Created';
        }
        field(12; "URL.FQ"; Text[250])
        {
            DataClassification = SystemMetadata;
            Caption = 'URL';
            ExtendedDatatype = URL;
        }
        field(15; "Status.FQ"; Enum "TB-Status.FQ")
        {
            DataClassification = SystemMetadata;
            Caption = 'Status';
        }
        field(16; "Error.FQ"; Text[200]) { DataClassification = SystemMetadata; Caption = 'Error'; }
        field(20; "File Uploaded.FQ"; DateTime) { DataClassification = ToBeClassified; Caption = 'File Uploaded'; }
    }

    keys
    {
        key(Key1; "Entry No..FQ")
        {
            Clustered = true;
        }
    }

    var


    trigger OnInsert()
    var
        EntryNo: Integer;
    begin
        Rec."File Created.FQ" := CurrentDateTime();
    end;

    procedure InsertLog(_fileName: Text[250]; _fullURL: Text[250]; _start: Date; _end: Date; _status: Enum "TB-Status.FQ"; _error: Text[200]; _overwrite: Boolean)
    var
    begin
        if (not _overwrite) or (Rec."Entry No..FQ" = 0) then begin
            Rec.Init();
            Rec."Entry No..FQ" := GetNextEntryNo();
            Rec.Insert(true);
        end else
            Rec.Get("Entry No..FQ");
        Rec."File Name.FQ" := CopyStr(_fileName, 1, StrLen(_fileName));
        Rec."URL.FQ" := CopyStr(_fullURL, 1, StrLen(_fullURL));
        Rec."Start Date.FQ" := _start;
        Rec."End Date.FQ" := _end;
        Rec."Status.FQ" := _status;
        Rec."Error.FQ" := CopyStr(_error, 1, MaxStrLen(Rec."Error.FQ"));
        Rec."File Uploaded.FQ" := CurrentDateTime();
        Rec.Modify(true);
    end;

    procedure GetNextEntryNo(): Integer
    var
        _lastentryno: Integer;
        _rec2: Record "Trial Balance Run.FQ";
    begin
        if _rec2.FindLast() then
            exit(_rec2."Entry No..FQ" + 1)
        else
            exit(1);
    end;
}