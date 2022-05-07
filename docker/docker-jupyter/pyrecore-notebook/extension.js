/* RECore-PyRECore --- A Python library for control of RECore

   Copyright (c) 2021 Omniment, Inc.

   Permission is hereby granted, free of charge, to any person obtaining a copy
   of this software and associated documentation files (the "Software"), to deal
   in the Software without restriction, including without limitation the rights
   to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
   copies of the Software, and to permit persons to whom the Software is
   furnished to do so, subject to the following conditions:

   The above copyright notice and this permission notice shall be included in
   all copies or substantial portions of the Software.

   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
   AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
   OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
   SOFTWARE. */

define([
  'base/js/namespace'
], function(
  Jupyter
) {
  let interrupting = false

  function interrupt_recore() {
    // We need to wait a moment before interruption for avoiding kernel death.
    setTimeout(function() {
      const comm = Jupyter.notebook.kernel.comm_manager.new_comm(
        'pyrecore.events',
        {'type': 'interrupt'}
      )
      comm.close()
    }, 10)
  }

  function load_ipython_extension() {
    // Overwrites an interrupt-kernel action.
    const action = Jupyter.actions.get('jupyter-notebook:interrupt-kernel')
    const old_handler = action.handler
    action.handler = function(env, event) {
      interrupting = true
      old_handler(env, event)
      interrupt_recore()
    }

    Jupyter.notebook.events.on('execute.CodeCell', function() {
      interrupting = false
    })

    Jupyter.notebook.events.on('finished_execute.CodeCell', function() {
      if (interrupting === true) {
        interrupting = false
        interrupt_recore()
      }
    })

  }

  return {
    load_ipython_extension: load_ipython_extension
  };
});
