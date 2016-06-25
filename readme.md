# syscall64ref

Search for x64 system calls and function prototype using man pages

## examples

```
shell ~>$ . syscall64.sh # load source
searching unistd_64.h ...
found: /usr/include/asm/unistd_64.h
shell ~>$ syscall64ref 1 2 3 4
syscall_number -> 1 | syscall_name -> write

       #include <unistd.h>

       ssize_t write(int fd, const void *buf, size_t count);

+---------------+--------+-----------------+--------------+
| rax           | rdi    | rsi             | rdx          |
+---------------+--------+-----------------+--------------+
| ssize_t write | int fd | const void *buf | size_t count |
+---------------+--------+-----------------+--------------+

syscall_number -> 2 | syscall_name -> open

       #include <sys/types.h>
       #include <sys/stat.h>
       #include <fcntl.h>

       int open(const char *pathname, int flags);

+----------+----------------------+-----------+
| rax      | rdi                  | rsi       |
+----------+----------------------+-----------+
| int open | const char *pathname | int flags |
+----------+----------------------+-----------+

syscall_number -> 3 | syscall_name -> close

       #include <unistd.h>

       int close(int fd);

+-----------+--------+
| rax       | rdi    |
+-----------+--------+
| int close | int fd |
+-----------+--------+

syscall_number -> 4 | syscall_name -> stat

       #include <sys/types.h>
       #include <sys/stat.h>
       #include <unistd.h>

       int stat(const char *pathname, struct stat *buf);

+----------+----------------------+------------------+
| rax      | rdi                  | rsi              |
+----------+----------------------+------------------+
| int stat | const char *pathname | struct stat *buf |
+----------+----------------------+------------------+

shell ~>$ syscall64ref socket bind listen accept
syscall_number -> 41 | syscall_name -> socket

       #include <sys/types.h>          
       #include <sys/socket.h>

       int socket(int domain, int type, int protocol);

+------------+------------+----------+--------------+
| rax        | rdi        | rsi      | rdx          |
+------------+------------+----------+--------------+
| int socket | int domain | int type | int protocol |
+------------+------------+----------+--------------+

syscall_number -> 49 | syscall_name -> bind

       #include <sys/types.h>          
       #include <sys/socket.h>

       int bind(int sockfd, const struct sockaddr *addr,
                socklen_t addrlen);

+----------+------------+-----------------------------+-------------------+
| rax      | rdi        | rsi                         | rdx               |
+----------+------------+-----------------------------+-------------------+
| int bind | int sockfd | const struct sockaddr *addr | socklen_t addrlen |
+----------+------------+-----------------------------+-------------------+

syscall_number -> 50 | syscall_name -> listen

       #include <sys/types.h>          
       #include <sys/socket.h>

       int listen(int sockfd, int backlog);

+------------+------------+-------------+
| rax        | rdi        | rsi         |
+------------+------------+-------------+
| int listen | int sockfd | int backlog |
+------------+------------+-------------+

syscall_number -> 43 | syscall_name -> accept

       #include <sys/types.h>          
       #include <sys/socket.h>

       int accept(int sockfd, struct sockaddr *addr, socklen_t *addrlen);

+------------+------------+-----------------------+--------------------+
| rax        | rdi        | rsi                   | rdx                |
+------------+------------+-----------------------+--------------------+
| int accept | int sockfd | struct sockaddr *addr | socklen_t *addrlen |
+------------+------------+-----------------------+--------------------+

```
