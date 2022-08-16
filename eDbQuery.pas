unit eDbQuery;

interface

uses
  System.SysUtils,IdHTTP,System.JSON,System.Classes,Vcl.Dialogs,Data.DB,REST.Response.Adapter;

 type TeDbquery = class
   private
    Ffields: string;
    Fconvert: string;
    Fdebug: Boolean;
    Flook: string;
    Fquery: string;
    Fport: string;
    Fcollection: string;
    Fsecondary_query: string;
    Fhost: string;
    Fviews: string;
    procedure Setcollection(const Value: string);
    procedure Setconvert(const Value: string);
    procedure Setdebug(const Value: Boolean);
    procedure Setfields(const Value: string);
    procedure Sethost(const Value: string);
    procedure Setlook(const Value: string);
    procedure Setport(const Value: string);
    procedure Setquery(const Value: string);
    procedure Setsecondary_query(const Value: string);
    procedure Setviews(const Value: string);

   public
      property host:string read Fhost write Sethost;
      property port:string read Fport write Setport;
      property debug:Boolean read Fdebug write Setdebug;
      property collection:string read Fcollection write Setcollection;
      property views:string read Fviews write Setviews;
      property fields:string read Ffields write Setfields;
      property convert:string read Fconvert write Setconvert;
      property query:string read Fquery write Setquery;
      property look:string read Flook write Setlook;
      property secondary_query:string read Fsecondary_query write Setsecondary_query;
      function getQuery:TJSONArray;
      procedure JsonToDataset(aDataset : TDataSet; aJSON : string);


 end;

implementation

{ TeDbquery }

function TeDbquery.getQuery: TJSONArray;
var
lHTTP : TIdHTTP;
objeto: TJSONArray;
_result:string;
json:string;
payload: TStringStream;
_resultDb:TDataSet;
_exception: TJSONObject;
begin

     payload := TStringStream.Create();
     payload.WriteString('{');
     payload.WriteString('"collection":'+Fcollection.QuotedString('"'));
     payload.WriteString(',"views":'+Fviews.QuotedString('"'));
     payload.WriteString(',"fields":'+Ffields.QuotedString('"'));
     payload.WriteString(',"query":'+Fquery.QuotedString('"'));


     if Length(Fconvert) > 0 then begin
       payload.WriteString(',"convert":'+Fconvert.QuotedString('"'));
     end;
     if Length(Flook) > 0 then begin
       payload.WriteString(',"look":'+Flook.QuotedString('"'));
     end;
     if Length(Fsecondary_query) > 0 then begin
       payload.WriteString(',"secondary_query":'+Fsecondary_query.QuotedString('"'));
     end;

     payload.WriteString('}');


     lHTTP := TIdHTTP.Create(nil);
     try
       lHTTP.Request.ContentType := 'application/json';
       lHTTP.Request.CharSet := 'UTF-8';
       //Exit;
       try
       _result := lHTTP.post('http://'+Fhost+':'+Fport+'/query',payload);
       except
         on e: exception do
         begin
          ShowMessage('ERRO ['+e.Message+'] ao tentar conectar ao servidor.');
          Exit;
         end;
       end;
       json :=  _result;
       try
         objeto := TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes(json),0) as TJSONArray;
       except
          objeto     := TJSONObject.ParseJSONValue('[{"ERROR":"True"}]') as TJSONArray;
          _exception := TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes(json),0) as TJSONObject;
          if Fdebug = True then begin
             if _exception.GetValue('result').Value = 'False' then
             begin
               ShowMessage(_exception.GetValue('exception').Value);
             end;
          end;
       end;
     finally
       lHTTP.Free;
     end;

     payload.Free;
     Result := objeto;

end;

procedure TeDbquery.JsonToDataset(aDataset: TDataSet; aJSON: string);
var
  JObj: TJSONArray;
  vConv : TCustomJSONDataSetAdapter;
begin
  if (aJSON = EmptyStr) then
  begin
    Exit;
  end;

  JObj := TJSONObject.ParseJSONValue(aJSON) as TJSONArray;
  vConv := TCustomJSONDataSetAdapter.Create(Nil);

  try
    vConv.Dataset := aDataset;
    vConv.UpdateDataSet(JObj);
  finally
    vConv.Free;
    JObj.Free;
  end;
end;

procedure TeDbquery.Setcollection(const Value: string);
begin
  Fcollection := Value;
end;

procedure TeDbquery.Setconvert(const Value: string);
begin
  Fconvert := Value;
end;

procedure TeDbquery.Setdebug(const Value: Boolean);
begin
  Fdebug := Value;
end;

procedure TeDbquery.Setfields(const Value: string);
begin
  Ffields := Value;
end;

procedure TeDbquery.Sethost(const Value: string);
begin
  Fhost := Value;
end;

procedure TeDbquery.Setlook(const Value: string);
begin
  Flook := Value;
end;

procedure TeDbquery.Setport(const Value: string);
begin
  Fport := Value;
end;

procedure TeDbquery.Setquery(const Value: string);
begin
  Fquery := Value;
end;

procedure TeDbquery.Setsecondary_query(const Value: string);
begin
  Fsecondary_query := Value;
end;

procedure TeDbquery.Setviews(const Value: string);
begin
  Fviews := Value;
end;

end.
