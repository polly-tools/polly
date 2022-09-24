module.exports = function(req){

  let parsed, query;

  if(req.method === 'GET'){
    const {data, ...rest} = req.query;
    query = rest;
    parsed = data ? JSON.parse(data) : {};
  }
  else if(req.method === 'POST'){
    query = req.query;
    parsed = req.body;
  }

  return {
    ...parsed,
    ...query
  }

}
