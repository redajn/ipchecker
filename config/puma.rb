threads_count = ENV.fetch('MAX_THREADS', 5)
threads threads_count, threads_count

port ENV.fetch('PORT', 9292)
environment ENV.fetch('RACK_ENV') { 'development' }

preload_app!
