//FINAL
/////Crear los nodos PalabrasEstímulo con una etiqueta diferente (Se usará más tarde)
LOAD CSV WITH HEADERS FROM "file:///Test1.csv" AS row
WITH row 
MERGE(e:PalabraEstimulo:Estimulo {name: row.ESTIMULO})
RETURN e
/////Crear los nodos PalabrasAsociadas y PalabrasAuxiliares (Esta nos servirá más tarde)
LOAD CSV WITH HEADERS FROM "file:///Test1.csv" AS row
WITH row WHERE NOT row.PALABRAS IS NULL
MERGE(a:PalabrasAuxiliares{name: row.PALABRAS, estimulo: row.ESTIMULO})
MERGE(pa:PalabrasAsociadas{name: row.PALABRAS})
RETURN a, pa
/////Eliminar los nodos de PalabrasAsociadas que no utilizaremos 
/////Estos nodos ya serán usados con los de PalabrasEstímulo
MATCH (e:PalabraEstimulo), (a:PalabrasAsociadas)
WHERE e.name = a.name
DELETE a
/////Crear una relación entre PalabrasEstimulo
MATCH (e:PalabraEstimulo), (a:Estimulo), (pa:PalabrasAuxiliares)
WHERE e.name = pa.estimulo AND a.name = pa.name
MERGE (e)<-[r:ASOCIA_CON]-(a) 
RETURN e, a
/////Crear una relación entre PalabrasEstimulo y PalabrasAsociadas
MATCH (e:PalabraEstimulo), (a:PalabrasAuxiliares), (pa:PalabrasAsociadas)
WHERE e.name = a.estimulo AND pa.name = a.name
MERGE (e)<-[r:ASOCIA_CON]-(pa) 
RETURN e, pa
/////Eliminar los nodos que sobran
MATCH (n:PalabrasAuxiliares) 
DELETE n 
/////Crear las propiedades de la relación de PalabrasEstimulo con PalabrasAsociadas, una vez ya creado todo
LOAD CSV WITH HEADERS FROM "file:///Test1.csv" AS row 
WITH row 
MATCH (e:PalabraEstimulo)<-[r:ASOCIA_CON]-(pa:PalabrasAsociadas) 
WHERE e.name=row.ESTIMULO AND pa.name=row.PALABRAS
SET r.frecuency=row.FRECUENCIA, r.time=row.`TIEMPO (S)`, r.association=row.`% ASOCIACION`
RETURN r
/////Crear las propiedades de la relación de PalabrasEstimulo con PalabrasEstimulo, una vez ya creado todo
LOAD CSV WITH HEADERS FROM "file:///Test1.csv" AS row 
WITH row 
MATCH (pe:PalabraEstimulo)<-[r:ASOCIA_CON]-(e:Estimulo) 
WHERE pe.name=row.ESTIMULO AND e.name=row.PALABRAS
SET r.frecuency=row.FRECUENCIA, r.time=row.`TIEMPO (S)`, r.association=row.`% ASOCIACION`
RETURN r