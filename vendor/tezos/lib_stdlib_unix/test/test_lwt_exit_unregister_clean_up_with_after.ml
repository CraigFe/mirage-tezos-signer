(*****************************************************************************)
(*                                                                           *)
(* Open Source License                                                       *)
(* Copyright (c) 2020 Nomadic Labs <contact@nomadic-labs.com>                *)
(*                                                                           *)
(* Permission is hereby granted, free of charge, to any person obtaining a   *)
(* copy of this software and associated documentation files (the "Software"),*)
(* to deal in the Software without restriction, including without limitation *)
(* the rights to use, copy, modify, merge, publish, distribute, sublicense,  *)
(* and/or sell copies of the Software, and to permit persons to whom the     *)
(* Software is furnished to do so, subject to the following conditions:      *)
(*                                                                           *)
(* The above copyright notice and this permission notice shall be included   *)
(* in all copies or substantial portions of the Software.                    *)
(*                                                                           *)
(* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR*)
(* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,  *)
(* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL   *)
(* THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER*)
(* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING   *)
(* FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER       *)
(* DEALINGS IN THE SOFTWARE.                                                 *)
(*                                                                           *)
(*****************************************************************************)

open Lwt.Infix

let r = ref 2

let clean_up_callback_id =
  Lwt_exit.register_clean_up_callback ~loc:__LOC__ (fun _ ->
      Lwt_unix.sleep 0.01
      >>= fun () ->
      r := !r * 3 ;
      Lwt.return_unit)

let _ =
  Lwt_exit.register_clean_up_callback
    ~loc:__LOC__
    ~after:[clean_up_callback_id]
    (fun _ ->
      Lwt_unix.sleep 0.01
      >>= fun () ->
      r := !r * 5 ;
      Lwt.return_unit)

let () =
  match
    Lwt_main.run
    @@ Lwt_exit.wrap_and_error
         ( Lwt_unix.sleep 0.01
         >>= fun () ->
         Lwt_exit.unregister_clean_up_callback clean_up_callback_id ;
         Lwt_unix.sleep 0.01 >>= fun () -> Lwt_exit.exit_and_raise 10 )
  with
  | Error 10 ->
      assert (!r = 10)
  | Error _ ->
      assert false
  | Ok _ ->
      assert false
