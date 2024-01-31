package log

import (
	"github.com/fapiper/onchain-access-control/config"
	"github.com/sirupsen/logrus"
	"io"
	"os"
	"strconv"
	"time"
)

// Init configures the logger to logs to the given location and returns a file pointer to a logs
// file that should be closed upon server shutdown
func Init(level, location string) *os.File {
	if level != "" {
		logLevel, err := logrus.ParseLevel(level)
		if err != nil {
			logrus.WithError(err).Errorf("could not parse log level<%s>, setting to info", level)
			logrus.SetLevel(logrus.InfoLevel)
		} else {
			logrus.SetLevel(logLevel)
		}
	}

	logrus.SetFormatter(&logrus.JSONFormatter{
		DisableTimestamp: false,
		PrettyPrint:      true,
	})
	logrus.SetReportCaller(true)

	// set logs config from config file
	now := time.Now()
	logrus.SetOutput(os.Stdout)
	if location != "" {
		logFile := location + "/" + config.ServiceName + "-" + now.Format(time.DateOnly) + "-" + strconv.FormatInt(now.Unix(), 10) + ".log"
		file, err := os.OpenFile(logFile, os.O_CREATE|os.O_WRONLY|os.O_APPEND, 0666)
		if err != nil {
			logrus.WithError(err).Warn("failed to create logs file, using default stdout")
		} else {
			mw := io.MultiWriter(os.Stdout, file)
			logrus.SetOutput(mw)
		}
		return file
	}
	return nil
}
