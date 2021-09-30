codeunit 70000 "Trial Balance Wrapper.FQ"
{
    trigger OnRun()
    var
        _inStr: InStream;
        _blob: Codeunit "Temp Blob";
        _error: Text;
        _status: Enum "TB-Status.FQ";
        TempExcelBuff: Record "Excel Buffer" temporary;
    begin

        CheckSetup();

        CreateAndFillExcelBuff(TempExcelBuff);

        ExportExcelToBuff(TempExcelBuff, _blob);

        _blob.CreateInStream(_inStr);

        AzurePutRequest(_inStr, _error, _status);

        TBRun.InsertLog(SetFileName(), SetFullURL(), AccountingPeriodStart, AccountingPeriodEnd, _status, _error, OverWrite);
    end;

    procedure CheckSetup()
    begin
        customSetup.Get();
        customSetup.TestField("Account URL.FQ");
        customSetup.TestField("Container.FQ");
        customSetup.TestField("SAS Token.FQ");
    end;

    procedure SetDates()
    var
        _accountingPeriod, _accountingPeriod2 : Record "Accounting Period";
    begin
        _accountingPeriod.SetFilter("Starting Date", '..%1', Today);
        _accountingPeriod.FindLast();
        AccountingPeriodEnd := CalcDate('-1D', _accountingPeriod."Starting Date");
        _accountingPeriod2 := _accountingPeriod;
        _accountingPeriod2.Find('<');
        AccountingPeriodStart := _accountingPeriod2."Starting Date";
    end;

    procedure SetDates(_start: Date; _end: Date)
    begin
        AccountingPeriodStart := _start;
        AccountingPeriodEnd := _end;
    end;

    procedure GetDates(var _start: Date; var _end: Date)
    begin
        _start := AccountingPeriodStart;
        _end := AccountingPeriodEnd;
    end;

    local procedure CreateAndFillExcelBuff(var TempExcelBuff: Record "Excel Buffer" temporary)
    begin
        TempExcelBuff.CreateNewBook('Data');
        FillExcelBuff(TempExcelBuff);
        TempExcelBuff.WriteSheet(HeaderTxt, CompanyName, UserId);
        TempExcelBuff.CloseBook();
    end;

    local procedure FillExcelBuff(var TempExcelBuff: Record "Excel Buffer" temporary)
    var
        GLAccount: Record "G/L Account";
    begin
        GLAccount.SetFilter("Date Filter", StrsubstNo('%1..%2', AccountingPeriodStart, AccountingPeriodEnd));
        GLAccount.SetAutoCalcFields("Balance at Date", "Net Change");
        FillExcelHeader(TempExcelBuff);
        if GLAccount.FindSet() then
            repeat
                FillExcelRow(TempExcelBuff, GLAccount);
            until GLAccount.Next() = 0;
    end;

    local procedure ExportExcelToBuff(var TempExcelBuff: Record "Excel Buffer" temporary; var _blob: Codeunit "Temp Blob")
    var
        _outStr: Outstream;
    begin
        _blob.CreateOutStream(_outStr);
        TempExcelBuff.SaveToStream(_outStr, true);
    end;

    local procedure FillExcelRow(var TempExcelBuff: Record "Excel Buffer" temporary; GLAccount: Record "G/L Account")
    var
        TempGlAcc: Record "G/L Account";
    begin
        if customSetup."Only G/L Acc. with balance.FQ" then
            if GLAccount."Balance at Date" = 0 then
                exit;
        TempExcelBuff.NewRow();
        TempExcelBuff.AddColumn(GLAccount."No.", false, '', false, false, false, '', TempExcelBuff."Cell Type"::Text);
        TempExcelBuff.AddColumn(GLAccount.Name, false, '', false, false, false, '', TempExcelBuff."Cell Type"::Text);
        if customSetup."Extr. Open Bal. for period.FQ" then
            TempExcelBuff.AddColumn(GetOpenBalance(GLAccount), false, '', false, false, false, '', TempExcelBuff."Cell Type"::Number);
        if customSetup."Extr. Net Change for period.FQ" then
            TempExcelBuff.AddColumn(GLAccount."Net Change", false, '', false, false, false, '', TempExcelBuff."Cell Type"::Number);
        TempExcelBuff.AddColumn(GLAccount."Balance at Date", false, '', false, false, false, '', TempExcelBuff."Cell Type"::Number);
    end;

    local procedure GetStreamLen(var _inStr: InStream) _len: Integer
    var
        memoryStream: Codeunit "MemoryStream Wrapper";
    begin
        memoryStream.Create(0);
        memoryStream.ReadFrom(_inStr);
        _len := memoryStream.Length();
        memoryStream.SetPosition(0);
        memoryStream.GetInStream(_inStr);
    end;

    local procedure SetFileName() _filename: Text
    var
        _char2Repl: Label '/';
        _char2ReplWith: Label '-';
        _start: Text;
        _end: Text;
    begin
        _start := ConvertStr(Format(AccountingPeriodStart), _char2Repl, _char2ReplWith);
        _end := ConvertStr(Format(AccountingPeriodEnd), _char2Repl, _char2ReplWith);

        _filename := StrSubstNo('%1-%2-%3.xlsx', 'Trial-Balance', _start, _end);
    end;

    local procedure SetFullURL() _fullURL: Text
    begin
        _fullURL := StrSubstNo('%1/%2/%3?%4', customSetup."Account URL.FQ",
                                                customSetup."Container.FQ",
                                                SetFileName(),
                                                customSetup."SAS Token.FQ");
    end;

    local procedure AzurePutRequest(var _inStr: InStream; var _error: Text; var _status: Enum "TB-Status.FQ")
    var
        _client: HttpClient;
        response: HttpResponseMessage;
        content: HttpContent;
        headers: HttpHeaders;
    begin
        _client.SetBaseAddress(customSetup."Account URL.FQ");
        content.WriteFrom(_inStr);
        content.GetHeaders(headers);
        headers.Remove('Content-Type');
        headers.Add('Content-Type', 'application/octet-stream');
        headers.Add('Content-Length', StrSubstNo('%1', GetStreamLen(_inStr)));
        headers.Add('x-ms-blob-type', 'BlockBlob');

        if not _client.Put(SetFullURL(), content, response) then begin
            _error := GetLastErrorText();
            _status := _status::Error;
        end;

        if response.IsSuccessStatusCode() then
            _status := _status::Uploaded
        else begin
            _error := response.ReasonPhrase;
            _status := _status::Error;
        end;
    end;

    local procedure GetOpenBalance(GLAccount: Record "G/L Account"): Decimal
    var
        TempGLAcc: Record "G/L Account";
    begin
        TempGLAcc.Get(GLAccount."No.");
        TempGLAcc.SetRange("Date Filter", CalcDate('-1D', AccountingPeriodStart));
        TempGLAcc.CalcFields("Balance at Date");
        exit(TempGLAcc."Balance at Date");
    end;

    local procedure FillExcelHeader(var TempExcelBuff: Record "Excel Buffer" temporary)
    begin
        TempExcelBuff.NewRow();
        TempExcelBuff.AddColumn('G/L Account No.', false, '', false, false, false, '', TempExcelBuff."Cell Type"::Text);
        TempExcelBuff.AddColumn('G/L Account Name', false, '', false, false, false, '', TempExcelBuff."Cell Type"::Text);
        if customSetup."Extr. Open Bal. for period.FQ" then
            TempExcelBuff.AddColumn('Open Balance', false, '', false, false, false, '', TempExcelBuff."Cell Type"::Number);
        if customSetup."Extr. Net Change for period.FQ" then
            TempExcelBuff.AddColumn('Net Change', false, '', false, false, false, '', TempExcelBuff."Cell Type"::Number);
        TempExcelBuff.AddColumn('Balance', false, '', false, false, false, '', TempExcelBuff."Cell Type"::Number);
    end;

    procedure SetOverWrite(_overwrite: boolean)
    begin
        OverWrite := _overwrite;
    end;

    procedure SetRec(var _rec: Record "Trial Balance Run.FQ")
    begin
        TBRun := _rec;
    end;


    var
        customSetup: Record "Cutom Setup.FQ";
        TBRun: Record "Trial Balance Run.FQ";
        AccountingPeriodStart, AccountingPeriodEnd : Date;
        XMLParams: Text;
        OverWrite: Boolean;
        HeaderTxt: Label 'Trial Balance';
}