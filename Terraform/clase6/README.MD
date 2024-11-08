# Ejercicio
Bajo este titular se especificará que es lo que se busca lograr

## Recursos de investigación
En caso de que se reciba algún enlace de ayuda antes de iniciar el ejercicio 

## Ejecución
Detalles del camino que seguí para completar el ejercicio

### Error X
Detalles de los errores encontrados

#### Solución
Su solución

## Conclusiones



### \<variantes>
En esta carpeta pondré ejercicios similares que se me hayan ocurrido usando el ejercicio real como base, la estructura del archivo README será el mismo.

### Error 
```txt
❯ terraform validate
╷
│ Error: Invalid reference
│ 
│   on main.tf line 62, in resource "aws_lb_listener" "Listener":
│   62:     type = forward
│ 
│ A reference to a resource type must be followed by at least one attribute access, specifying the resource name.
╵
```
Se cambia la línea type = forward a type = "forward" 


### Error
```txt
╷
│ Error: Reference to undeclared resource
│ 
│   on main.tf line 65, in resource "aws_lb_listener" "Listener":
│   65:       arn = aws_lb_listener_group.Grupo.id
│ 
│ A managed resource "aws_lb_listener_group" "Grupo" has not been declared in the root module.
╵
```
Error de tipeo, se debe apuntar al aws_target_group y no al aws_lb_listener_group




