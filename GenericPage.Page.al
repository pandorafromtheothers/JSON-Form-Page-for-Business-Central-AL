/// <summary>
/// */*/*/*/*/*/**/*/*/*/*/*/**/*/*/*/*/*/**/*/*/*/*/*/**/*/*/*/*/*/*
/// Made by 
/// @GitHub
/// pandorafromtheothers
/// 
/// @Twitter/X
/// deadpan_dora
/// */*/*/*/*/*/**/*/*/*/*/*/**/*/*/*/*/*/**/*/*/*/*/*/**/*/*/*/*/*/*
/// 
/// 
/// HOW TO USE:
/// 
/// To Make a JSON Object
/// 1. Create a JSON object and all of it's values must be filled with the procedure DefaultValue().
/// 2. Pass this JSON object to the procedure MakeJSONObjectWithTokenSelectionPage(), and pass another JSON object for the result.
/// 3. Done.
/// 
/// 
/// To open a window with a single value and receive the input value of it:
/// 1. Call the procedure SetVisibile() and pass a name for the field name, and pass a value that you want to make visible.
/// Example: To have a popup window with a Boolean type: SetVisible('PayPal method', true)
/// 
/// 2. Run the window modally as you would with a Lookup page, then after the OK, call the procedure GetPageValue() with, again, a value you want to receive.
/// This return a JsonValue, so you have to write how you want to receive it.
/// Example: To receive a Text Value: GetPageValue('').AsText()
/// 
/// 3.Done
/// 
/// !!!
/// Use the Test Page to see it in action.
/// !!!
/// </summary>
page 50280 "Generic Page"
{
    Caption = 'Generic Page';
    UsageCategory = None;
    SourceTable = "Integer";
    SourceTableTemporary = true;
    PageType = StandardDialog;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(content)
        {
            group(General)
            {
                usercontrol(ReSizer; LabelReSizer)
                {
                    ApplicationArea = All;
                    Visible = true;
                }
                field(LabelVar; LabelVar)
                {
                    Caption = '';
                    ApplicationArea = All;
                    MultiLine = true;
                    Editable = false;
                }
                field(TextVar; TextVar)
                {
                    Caption = '';
                    ApplicationArea = All;
                    Visible = SeeText;
                }
                field(DecimalVar; DecimalVar)
                {
                    Caption = '';
                    ApplicationArea = All;
                    Visible = SeeDecimal;
                }
                field(BooleanVar; BooleanVar)
                {
                    Caption = '';
                    ApplicationArea = All;
                    Visible = SeeBoolean;
                }
                field(DateVar; DateVar)
                {
                    Caption = '';
                    ApplicationArea = All;
                    Visible = SeeDate;
                }
            }
        }
    }
    #region General
    local procedure ConvertToDecimal(joker: Text): Decimal
    var
        _tempDecimal: Decimal;
    begin
        if (Evaluate(_tempDecimal, joker)) then exit(_tempDecimal);
    end;

    local procedure GetElement(name: Text; obj: JsonObject): JsonToken
    var
        _tempToken: JsonToken;
    begin
        obj.Get(name, _tempToken);
        exit(_tempToken);
    end;
    #endregion


    /// <summary>
    /// You can select the few tokens you want to fill on a JSONObject. Other values set to null if checked, or they will have their default value.
    /// </summary>
    /// <param name="baseRequest"></param>
    /// <param name="result"></param>
    /// <returns></returns>
    procedure MakeJSONObjectWithTokenSelectionPage(baseRequest: JsonObject; var result: JsonObject): Boolean
    var
        _key: Text;
        _selectedToken: Text;
        _p: Page "Generic Page";
        _rawBase, _partialRequest : JsonObject;
        _temp: Variant;
        _nullToken: JsonToken;
        _setEmptyToNull: Boolean;
        _partialTokenValue: JsonToken;
        _tempText: Text;
        _tempBool: Boolean;
    begin
        _rawBase := baseRequest;
        _p.SetVisibile(GetTokenCatalogText(baseRequest), _tempText);
        _p.SetVisibile('', _tempBool);
        _p.LookupMode(true);
        if _p.RunModal() <> Action::LookupOK then
            exit;

        if _p.GetPageValue(_tempText).AsText() <> '' then begin
            _setEmptyToNull := _p.GetPageValue(_tempBool).AsBoolean();
            foreach _key in _p.GetPageValue(_tempText).AsText().TrimStart(',').TrimEnd(',').Split(',') do begin
                if ConvertToDecimal(_key) > 0 then begin
                    _selectedToken := baseRequest.Keys().Get(ConvertToDecimal(_key));
                    _partialTokenValue := GetElement(_selectedToken, baseRequest);
                    _partialRequest.Add(_selectedToken, _partialTokenValue);
                end;
            end;
            if not MakeRequestWithPages(_partialRequest, _partialRequest) then
                exit;
            foreach _key in baseRequest.Keys do
                if _partialRequest.Contains(_key) then
                    baseRequest.Replace(_key, GetElement(_key, _partialRequest))
                else
                    if _setEmptyToNull then
                        baseRequest.Replace(_key, _nullToken)
                    else
                        baseRequest.Replace(_key, GetDefaultValueAndFieldTypeByText(GetElement(_key, baseRequest), _temp));
        end else
            if not MakeRequestWithPages(baseRequest, baseRequest) then
                exit;

        result := baseRequest;
        exit(_rawBase.Keys.Count = result.Keys.Count);
    end;

    #region Modify these to extend the variety of variables
    procedure DefaultValue(fT: FieldType): Text
    begin
        case fT of
            FieldType::Text, FieldType::Code:
                exit(BaseTextLbl);
            FieldType::Decimal, FieldType::Integer:
                exit(BaseNumericLbl);
            FieldType::Boolean:
                exit(BaseBooleanLbl);
            FieldType::Date:
                exit(BaseDateLbl);
        end;
    end;

    procedure GetPageValue(typeVariant: Variant) result: JsonValue
    begin
        if typeVariant.IsText or typeVariant.IsCode then
            result.SetValue(TextVar);
        if typeVariant.IsDecimal or typeVariant.IsInteger then
            result.SetValue(DecimalVar);
        if typeVariant.IsBoolean then
            result.SetValue(BooleanVar);
        if typeVariant.IsDate then
            result.SetValue(DateVar);
    end;

    local procedure GetDefaultValueAndFieldTypeByText(fieldTypeValueText: JsonToken; var type: Variant) valueResult: JsonValue
    begin
        if fieldTypeValueText.IsValue then begin
            if fieldTypeValueText.AsValue().IsNull then
                Error('Current base object contains a null. Replace the null to a default value or remove the token.');
            case fieldTypeValueText.AsValue().AsText() of
                BaseNumericLbl:
                    begin
                        type := 0;
                        valueResult.SetValue(0);
                    end;
                BaseBooleanLbl:
                    begin
                        type := false;
                        valueResult.SetValue(false);
                    end;
                BaseDateLbl:
                    begin
                        type := Today();
                        valueResult.SetValue(Today());
                    end;
                BaseTextLbl:
                    begin
                        type := '';
                        valueResult.SetValue('');
                    end;
            end;
        end;
    end;

    procedure SetVisibile(label: Text; visibleFieldType: Variant)
    begin
        if Rec.IsEmpty then begin
            Rec.Init();
            Rec.Number := 1;
            Rec.Insert();
        end;
        if LabelVar = '' then
            LabelVar := label;

        if visibleFieldType.IsText then begin
            SeeText := true;
            exit;
        end;
        if visibleFieldType.IsDecimal or visibleFieldType.IsInteger then begin
            SeeDecimal := true;
            exit;
        end;
        if visibleFieldType.IsBoolean then begin
            SeeBoolean := true;
            exit;
        end;
        if visibleFieldType.IsDate then begin
            SeeDate := true;
            exit;
        end;
    end;
    #endregion


    local procedure MakeRequestWithPages(baseRequest: JsonObject; var result: JsonObject): Boolean
    var
        _key: Text;
        _tempDecimal: Decimal;
        _tempBool: Boolean;
        _tempDate: Date;
        _v: Variant;
        _token: JsonToken;
        _objectResult: JsonObject;
        _valueResult: JsonValue;
    begin
        Clear(result);
        foreach _key in baseRequest.Keys do begin
            _token := GetElement(_key, baseRequest);
            if _token.IsValue then begin
                if not AddValueToRequest(_key, _token, _valueResult) then
                    exit;
                result.Add(_key, _valueResult);
            end;

            if _token.IsArray then
                result.Add(_key, AddArrayToRequest(_key, _token));

            if _token.IsObject then begin
                if not MakeJSONObjectWithTokenSelectionPage(_token.AsObject(), _objectResult) then
                    exit;
                result.Add(_key, _objectResult);
            end;
        end;
        exit(true);
    end;

    local procedure AddValueToRequest(keyArg: Text; singleToken: JsonToken; var result: JsonValue): Boolean
    var
        _p: Page "Generic Page";
        _fT: Variant;
    begin
        GetDefaultValueAndFieldTypeByText(singleToken, _fT);
        Clear(_p);
        _p.SetVisibile(keyArg, _fT);
        _p.LookupMode(true);
        if _p.RunModal() <> Action::LookupOK then
            exit;

        result := _p.GetPageValue(_fT);

        exit(true);
    end;

    local procedure ArrayCountPage(name: Text): Integer
    var
        _p: Page "Generic Page";
        _int: Integer;
    begin
        Clear(_p);
        _p.SetVisibile('Count of ' + name, _int);
        _p.LookupMode(true);
        if _p.RunModal() <> Action::LookupOK then
            exit;

        exit(_p.GetPageValue(_int).AsDecimal());
    end;

    local procedure AddArrayToRequest(keyArg: Text; arrayArg: JsonToken): JsonToken
    var
        _arrayValueResult: JsonValue;
        _tokenResult: JsonToken;
        _arrayToken: JsonToken;
        _objectResult: JsonObject;

        _result: JsonArray;
        _index: Integer;
    begin
        arrayArg.AsArray().Get(0, _arrayToken);

        for _index := 1 to ArrayCountPage(keyArg) do begin
            if _arrayToken.IsObject then begin
                Clear(_objectResult);
                if not MakeJSONObjectWithTokenSelectionPage(_arrayToken.AsObject(), _objectResult) then
                    exit;
                _tokenResult := _objectResult.AsToken();
            end;
            if _arrayToken.IsValue then begin
                if not AddValueToRequest('', _arrayToken, _arrayValueResult) then
                    exit;
                _tokenResult := _arrayValueResult.AsToken();
            end;

            _result.Add(_tokenResult);
        end;

        exit(_result.AsToken());
    end;

    local procedure GetTokenCatalogText(baseRequest: JsonObject): Text
    var
        _key: Text;
        _index: Integer;
        _tokenCatalogLine: TextBuilder;
        _fullText: TextBuilder;
    begin
        foreach _key in baseRequest.Keys do begin
            _index += 1;
            _tokenCatalogLine.AppendLine(Format(_index) + '-' + _key + GetBaseRequestDataTypeLbl(GetElement(_key, baseRequest)));
        end;
        _fullText.AppendLine('-Check the box to set undefined variables as null');
        _fullText.AppendLine('-Decide what you fill out! Separate the front numbers presented with commas(1,2,3)');
        _fullText.AppendLine(_tokenCatalogLine.ToText());
        exit(_fullText.ToText());
    end;

    local procedure GetBaseRequestDataTypeLbl(token: JsonToken): Text
    begin
        if token.IsValue then
            exit(' (value)');
        if token.IsObject then
            exit(' (object)');
        if token.IsArray then
            exit(' (array)');
    end;

    var
        LabelVar: Text;
        TextVar: Text;
        BaseTextLbl: Label '';
        BaseNumericLbl: Label '0';
        BaseBooleanLbl: Label 'false';
        BaseDateLbl: Label '2024';
        SeeText: Boolean;
        DecimalVar: Decimal;
        SeeDecimal: Boolean;
        BooleanVar: Boolean;
        SeeBoolean: Boolean;
        DateVar: Date;
        SeeDate: Boolean;
}

controladdin LabelReSizer
{
    MaximumHeight = 0;
    MaximumWidth = 0;
    RequestedHeight = 0;
    RequestedWidth = 0;
    StartupScript = 'Scripts/LabelResizer.js';
    Scripts = 'Scripts/LabelResizer.js';
}